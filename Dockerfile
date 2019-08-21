# 创建镜像，注意修改配置
$ docker build -t hbchen/echo-web:v0.0.1 .

# 运行容器
$ docker run
     -p 8081:8081
     --name=echo-web
     hbchen/echo-web:v0.0.1
