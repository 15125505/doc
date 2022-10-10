# 本脚本用于初始化go软件运行服务器
# 尽管本脚本可以多次运行，但只需要成功运行一次即可
# 运行本脚本时，需要关注脚本的运行日志，务必保证成功运行
# 本脚本将会自动安装nginx、wget并进行相应的配置
# 下方配置信息中的内容，是必须配置的

# 配置信息
sudoPwd='cur_user_passwd' # 当前用户密码
workPort='your_work_port' # 本程序的实际对外端口，如：30100

# 安装nginx并设置开机启动
echo "$sudoPwd" | sudo -S yum install nginx wget -y

# 开机启动nginx
echo "$sudoPwd" | sudo -S systemctl enable nginx

# 启动nginx
echo "$sudoPwd" | sudo -S systemctl start nginx

# 创建服务所使用的模板文件
echo "server {
    listen       $workPort;
    server_name  _;
    root         /usr/share/nginx/html;

    access_log  /var/log/nginx/access.log;

    location / {
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP  \$remote_addr;
            proxy_set_header X-Forwarded-For \$remote_addr;
            proxy_pass http://127.0.0.1:CurModePort; # 当前工作模式的端口
    }

    error_page 404 /404.html;
    location = /404.html {
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
    }
}" >me.conf.tpl

#获取脚本所在路径
cd "$(dirname "$0")" || exit 1
svrFolderPath=$(pwd) # 服务程序本地目录

# 设置开机启动
echo "[Unit]
      Description=startVer$workPort
      After=network.target nginx.service
      [Service]
      Type=forking
      User=$(whoami)
      Group=$(whoami)
      ExecStart=/bin/bash $svrFolderPath/startVer.sh
      ExecReload=/bin/bash $svrFolderPath/startVer.sh
      ExecStop=
      PrivateTmp=true
      TimeoutStartSec=600
      [Install]
      WantedBy=multi-user.target
" >startVer"$workPort".service
chmod 754 startVer"$workPort".service
echo "$sudoPwd" | sudo -S mv startVer"$workPort".service /lib/systemd/system/startVer"$workPort".service
echo "$sudoPwd" | sudo -S systemctl enable startVer"$workPort" # 保证开机启动