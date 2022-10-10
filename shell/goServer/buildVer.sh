# 本脚本用于在服务器编译go软件并提供下载
# 本脚本可以多次运行，每次git更新后，需要执行本脚本完成新版本的编译
# 考虑到每次运行本脚本，都会对当前git代码进行改动，因此建议仅在必要情况下运行本脚本
# 运行本脚本时，需要关注脚本的运行日志
# 下方配置信息中的内容，是必须配置的

# 配置信息
gitPath='your_git_addr'  # git地址，如git@github.com:15125505/doc.git
branch='your_git_branch' # git分支，如master

# 不需要修改的配置
verFilePathInProject="def/ver.go" # 写入版本号的版本文件地址
releasePath="$HOME/.output"       # 编译后的文件存放位置

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

# 解析项目地址
eInfo "从git地址中解析项目服务器地址"
gitServer=$(echo "$gitPath" | sed -n "s/git@\(.*\):.*/\1/p")
if [ "$gitServer" == "" ]; then
  eErr "从git地址中解析项目服务器地址失败，请检查git地址是否合法"
fi
eNotice "项目地址为 $gitServer"
ssh -o StrictHostKeyChecking=no "$gitServer"

# 解析exe名称
eInfo "从git地址中解析项目名称"
exeName=$(echo "$gitPath" | sed -n "s/.*\/\([a-zA-Z0-9_-]\+\)\.git/\1/p")
if [ "$exeName" == "" ]; then
  eErr "从git地址中解析项目名称失败，请检查git地址是否合法"
fi
eNotice "项目名称为 $exeName"

# 清空工作目录
workspace=".workspace"
eInfo "清空并进入工作目录"
rm -fr "$workspace"
mkdir "$workspace"
cd "$workspace" || eErr '进入工作目录失败'

# 拉取最新代码
eInfo "拉取最新代码"
if ! git clone "$gitPath" -b "$branch"; then
  eErr "拉取最新代码错误"
fi
cd "$(ls)" || eErr "进入代码根目录失败"

# 读取版本号
eInfo "读取版本号"
ver=$(sed -n 's/.*CurVersion\s*=\s*"\(v[0-9]\+\.[0-9]\+\.[0-9]\+\)".*/\1/p' "$verFilePathInProject")
if [ "$ver" == "" ]; then
  eErr "读取版本号失败"
fi
lastVerNum=$(echo "$ver" | grep -Eo "[0-9]*$")
lastVerPrefix=$(echo "$ver" | grep -Eo "v[0-9]*\.[0-9]*\.")

# 新版本号为最后一位版本加一
newVer="$lastVerPrefix$((lastVerNum + 1))"
eInfo "修改当前版本号：$ver 为新版本号：$newVer"
if ! sed -i "s/$ver/$newVer/" "$verFilePathInProject"; then
  eErr "更改版本号失败"
fi
echo "$newVer" >"$exeName".info

# 编译
eInfo "编译程序"
if ! go build; then
  eErr "编译发生错误"
fi

# 复制文件到输出目录
targetName="${exeName}_${newVer}"
eInfo "复制文件到输出目录"
mkdir -p "$releasePath"
if ! (cp "$exeName.info" "$exeName" "$releasePath/" && cp "$releasePath/$exeName" "$releasePath/$targetName"); then
  eErr "复制文件到输出目录失败"
fi

# 打tag
eInfo "添加Tag $newVer"
if ! (git add "$verFilePathInProject" && git commit -m "修改：版本号" && git push origin "$branch" && git tag -a "$newVer" -m "$newVer" && git push --tags); then
  eErr "添加新版本tag($newVer)失败"
fi
