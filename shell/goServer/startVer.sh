# 本脚本用于在服务器运行编译好的go程序（无缝热更）
# 本脚本可以多次运行，每次版本有更新时，需要运行此脚本完成版本更新
# 考虑到每次运行本脚本，都会切断当前用户正在进行的访问，因此建议仅在必要情况下运行本脚本
# 运行本脚本时，需要关注脚本的运行日志
# 下方配置信息中的内容，是必须配置的

# 配置参数
workPort='your_work_port'      # 本程序的实际对外端口，如：30100
downloadUrl="your_downloadUrl" # 版本文件下载地址，如：http://localhost:8080/projName
sudoPwd="curPasswd"            # 当前用户密码，用于重启nginx

# 计算参数
portA=$((workPort + 1)) # A模式所用端口
portB=$((workPort + 2)) # B模式所用端口
targetVersion=$1        # 参数目标版本号

# 信息提示
eInfo() {
  echo -e "\033[32m--$1...\033[0m\n"
}

# 信息提示
eNotice() {
  echo -e "\033[33m$1!\033[0m\n"
}

# 错误提示
eErr() {
  echo -e "\033[31m===$1！\033[0m\n"
  exit 2
}

eNotice "****任务开始****"

# 解析项目地址
eInfo "从下载地址中解析项目名称"
downloadPath=$(echo "$downloadUrl" | sed -n "s/\(http:\/\/.*\)\/\([^\/]*\)/\1/p")
exeName=$(echo "$downloadUrl" | sed -n "s/\(http:\/\/.*\)\/\([^\/]*\)/\2/p")
if [ "$exeName" == "" ] || [ "$downloadPath" == "" ]; then
  eErr "从下载地址中解析项目名称失败，请检查下载地址是否合法"
fi
eNotice "项目名称为 $exeName，下载地址目录为 $downloadPath"

eInfo "获取脚本所在路径"
cd "$(dirname "$0")" || eErr "获取脚本所在路径失败"
svrFolderPath=$(pwd) # 服务程序本地目录
eNotice "脚本所在路径为$svrFolderPath"

# 如果没有传入版本，则获取最新版本
if [ "$targetVersion" == "" ]; then
  eInfo "从版本服务器获取最新版本号"
  targetVersion=$(curl -s "$downloadPath/$exeName.info")
  if [ ${#targetVersion} -lt 1 ] || [ ${#targetVersion} -gt 100 ]; then
    eErr "从版本服务器获取最新版本号错误"
  fi
  eNotice "服务器最新版本号为$targetVersion"
fi

# 当前模式默认模式B
curPort=$portB
nextPort=$portA

# 判断当前使用模式, 如果当前模式不是A模式，则下一版本使用A模式
eInfo "判断当前使用模式"
if grep -E "proxy_pass\s+http://127.0.0.1:$portA" -q <"/etc/nginx/conf.d/$exeName.conf"; then
  # 使用模式B
  curPort=$portA
  nextPort=$portB
  eNotice "当前为A模式，因此即将使用B模式：端口$portB"
else
  eNotice "当前为B模式，因此即将使用A模式：端口$portA"
fi

# 下载可执行程序
exeNameVersion="$exeName""_$targetVersion"
localExeName="$exeName-$nextPort"
killExeName="$exeName-$curPort"
eNotice "----可执行程序<$exeNameVersion> 待启动程序<$localExeName> 当前版本程序<$killExeName>"

# 创建并进入端口目录
mkdir -p "$svrFolderPath/$nextPort"
cd "$svrFolderPath/$nextPort" || eErr "进入版本目录失败"

# 如果该进程正在运行，那么先删除
id=$(pgrep -f "$localExeName")
if [[ "$id" != "" ]]; then
  eInfo "需要启动的进程目前已经存在，首先干掉这个之前残留的进程"
  kill "$id"
fi

# 下载可执行程序到服务目录
eInfo "开始下载可执行程序"
if ! wget -q "$downloadPath/$exeNameVersion" -O "$localExeName"; then
  eErr "下载版本文件失败"
fi
eNotice "下载可执行程序成功"
chmod +x "$localExeName"

# 启动新版本
eInfo "启动新版本"
nohup "./$localExeName" >>"run.log" 2>&1 &

# 检测是否成功启动（等待1秒之后再检查，给与进程启动的时间）
sleep 1s
id=$(pgrep -f "$localExeName")
if [[ "$id" == "" ]]; then
  eErr "新版本未启动成功"
fi
eNotice "新版本启动成功"

# 修改nginx使用新的端口
eInfo "修改nginx使用新的端口"
echo "$sudoPwd" | sudo -S pwd
if ! sed "s/CurModePort/$nextPort/" "$svrFolderPath/me.conf.tpl" | sudo tee "/etc/nginx/conf.d/$exeName.conf"; then
  eErr "修改nginx配置失败"
fi

# 切换nginx
if ! echo "$sudoPwd" | sudo -S nginx -s reload; then
  eErr "重启nginx失败"
fi
eNotice "切换nginx成功"

# 检验版本信息
eInfo "检查版本号"
checkVer=$(curl -s "http://localhost:$workPort/verNum")
if [ "$checkVer" != "$targetVersion" ]; then
  eErr "版本号检查发生错误 targetVersion<$targetVersion> curVersion<$checkVer>"
  exit 4
fi
eNotice "版本号检查通过"

# 杀掉原有进程
id=$(pgrep -f "$killExeName")
if [[ "$id" != "" ]]; then
  eInfo "杀掉原有进程"
  kill "$id"
fi

eNotice "****任务启动成功****"
