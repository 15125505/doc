# 本脚本用于初始化go软件编译服务器
# 尽管本脚本可以多次运行，但只需要成功运行一次即可
# 运行本脚本时，需要关注脚本的运行日志，务必保证成功运行
# 本脚本将会自动安装nginx、git、go并进行相应的配置
# 下方配置信息中的内容，是必须配置的

# 配置信息
sudoPwd='cur_user_passwd'        # 当前用户密码
serverPort='download_port'       # 版本下载服务的端口，如8080
privateKey='your_git_privateKey' # git用的key，以类似-----BEGIN RSA PRIVATE KEY-----开头的一段内容

# 不需要修改的参数
serverDomain="localhost"                      # 版本下载服务的域名
releasePath="$HOME/.output"                   # 编译后的文件存放位置
confFileName="$serverDomain.$serverPort.conf" # nginx配置文件名称
keyFile="$HOME/.ssh/id_rsa"                   # git私钥存储位置

# 安装必要的软件
echo "$sudoPwd" | sudo -S yum install nginx git go -y

# 设置nginx，让nginx以root用户启动（这样才能访问用户目录下的文件）
echo "$sudoPwd" | sudo -S sed -i 's/\s*user\s*\w\+;/user root;/' /etc/nginx/nginx.conf

# 开机启动nginx
echo "$sudoPwd" | sudo -S systemctl enable nginx

# 启动nginx
echo "$sudoPwd" | sudo -S systemctl start nginx

# 设置下载服务
echo "
server {
    listen       $serverPort;
    server_name  $serverDomain;
    root $releasePath;
    access_log /var/log/nginx/$serverDomain.$serverPort.access.log;

    error_page 404 /404.html;
    location = /40x.html {}
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {}
}
" >"$confFileName"
echo "$sudoPwd" | sudo -S mv "$confFileName" /etc/nginx/conf.d/
mkdir -p "$releasePath"

# 重启nginx使得配置生效
echo "$sudoPwd" | sudo -S nginx -s reload

# 配置git拉取权限
mkdir -p "$HOME/.ssh/"
echo "$privateKey" >"$keyFile"
chmod 0600 "$keyFile"

# 设置go代理，不然拉取github上的代码太慢了
go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct

# 设置git基本参数
git config --global user.email "auto@build"
git config --global user.name "auto build Machine"
