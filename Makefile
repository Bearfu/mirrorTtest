list:
	@echo "sync-codes: 同步代码"
	@echo "image: 制作镜像"
	@echo "build: 编译可执行文件"
	@echo "upload: 上传本地镜像"
	@echo "publish: 同步最新代码，制作镜像并上传"

sync-codes:
	git pull

build:
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-w' -o server ./main.go

image: build
	@echo "start to make docker image..."
	docker build --tag="d-hub.wallstcn.com:5000/wallstreetcn/ivankadedicate:latest" .

upload:
	@echo "start to upload..."
	docker push d-hub.wallstcn.com:5000/wallstreetcn/ivankadedicate:latest

publish: sync-codes image upload

deps:
	mkdir -p /tmp/govendor/bin
	mkdir -p /go/src/gitlab.wallstcn.com/baoer/alliance
	cp -R /builds/baoer/alliance/$(PROJECT_NAME) /go/src/gitlab.wallstcn.com/baoer/alliance/$(PROJECT_NAME)/
	mv /go/src/gitlab.wallstcn.com/baoer/alliance/api-server/vendor/* /go/src/

test:
	@echo $(CONFIGOR_ENV)
	go test -v -cover -tags test -race ./...
