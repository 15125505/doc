# go进行sql查询遇到NULL字段的解决方法

mysql数据库查询数据时，经常出现查询的某个字段为NULL的情况。

然而这种情况在go语言中会出现一种很蛋疼的表现：**go在Scan结果的时候，会失败。**

## 案例

* 数据表是这样的

``` sql
CREATE TABLE `go_test`.`test_nulltest_null`( 
   `id` INT NOT NULL AUTO_INCREMENT , 
   `name` VARCHAR(200) , 
   `info` VARCHAR(500) , 
   PRIMARY KEY (`id`)
 );
 ```
 
* 里面的字段是这样的

``` sql
INSERT INTO `go_test`.`test_null`(`id`,`name`,`info`) VALUES ( NULL,'123',NULL);
```
 
* 读取内容的代码是这样的

``` go
func queryDb(db *sql.DB) {
	rows, err := db.Query("select * from go_test.test_null")
	if err != nil {
		fmt.Println("查询出错：" + err.Error())
	}
	defer rows.Close()

	for
	rows.Next() {
		var id int
		var name, info string
		if err = rows.Scan(&id, &name, &info); err != nil {
			fmt.Println("获取结果出错：" + err.Error())
			return
		}
		fmt.Println("id:", id, "name:", name, "info:", info)
	}
}
```

* 结果是这样的

``` 
获取结果出错：sql: Scan error on column index 2: unsupported Scan, storing driver.Value type <nil> into type *string 
```

很明显，这不是我们想要的结果，如果这个值木有，scan的时候给我们个空字符串也好啊，然而结果是报错了。下面研究一下解决方案。

# 一种可行的解决方案

对于可能为NULL的字段读取，go的sql模块提供了一个sql.NullString这样的东东来解析可能为NULL的字符串，对于浮点型或者整形也有类似的数据类型。很蛋疼的样子，不过可以解决问题，下面是遵照这种方案进行的修改。

* 代码进行如下修改

``` go
rows.Next() {
  var id int
  var name, info sql.NullString
  if err = rows.Scan(&id, &name, &info); err != nil {
    fmt.Println("获取结果出错：" + err.Error())
    return
  }
  fmt.Println("id:", id, "name:", name.String, "info:", info.String)
}
```

* 正常的结果如下

```
id: 1 name: 123 info: 
```

**按照这种解决方法，每次写go代码的时候，还得去顾及sql查询结果是否有NULL出现，肿么看都是很蛋疼的事情。好在sql语句有自己的解决方法，请继续向下看。**

# 更好的解决方案

如果思考go语言的时候，只需要思考go语言，sql的问题，在思考sql的时候解决是更好的方案。今天研究了一下mysql，发现sql语句本身也能解决这种问题。

* 优化的sql查询语句

``` sql
SELECT id, IFNULL(`name`, '') AS `name`, IFNULL(info, '') AS info FROM go_test.test_null
```

说明一下，增加的**IFNULL**判断，是在发现该字段为NULL的时候，返回另外一个值（此处用空字符串替代）。

* 现在把scan处的代码恢复原状，只是把sql语句修改一下，一切也都是OK的了
* 修改后完整的代码如下

``` go
func queryDb(db *sql.DB) {
	rows, err := db.Query("SELECT id, IFNULL(`name`, '') AS `name`, IFNULL(info, '') AS info FROM go_test.test_null")
	if err != nil {
		fmt.Println("查询出错：" + err.Error())
	}
	defer rows.Close()

	for
	rows.Next() {
		var id int
		var name, info string
		if err = rows.Scan(&id, &name, &info); err != nil {
			fmt.Println("获取结果出错：" + err.Error())
			return
		}
		fmt.Println("id:", id, "name:", name, "info:", info)
	}
}
```

## 总结陈词

**如果以后使用go进行sql查询的时候，为了避免在go中进行一些蛋疼的对NULL值的额外处理，可以考虑用sql的IFNULL语句来将可能的NULL值进行转化。**
