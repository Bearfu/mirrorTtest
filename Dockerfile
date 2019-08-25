#源镜像
FROM golang:latest
#作者
MAINTAINER Razil "303761829@qq.com"
#设置工作目录
WORKDIR $GOPATH/src/mirrorTest
COPY . $GOPATH/src/mirrorTest
#将服务器的go工程代码加入到docker容器中
#go构建可执行文件
RUN go build .
#暴露端口
EXPOSE 8082
#最终运行docker的命令
ENTRYPOINT  ["./mirrorTest"]
