FROM ccr.ccs.tencentyun.com/dhub.wscn.com/alpine:3.5
ENV CONFIGOR_ENV ivktest
ADD server /
ADD conf/ /conf
ENTRYPOINT [ "/server" ]
