# 网络传输分析

既然提供了wireshark 抓包文件，那么我们首先安装一个wireshark，载入获取到的文件开始分析。

![](https://raw.githubusercontent.com/Bearfu/pic/master/img/20190821163022.png)

一次网络请求最开始的步骤当然是对访问的网址进行DNS解析，获取到实际的访问IP。可以看到是页面顶部浅蓝色，编号为1-7封包。

![](https://raw.githubusercontent.com/Bearfu/pic/master/img/20190821163418.png)

可以看到这里从DNS服务器上获取到相应的网络IP地址为
139.217.146.62。

然后进入第二步 与相应的服务器进行TCP连接，可以看到，在封包8、9、10中本地服务器与远端服务器进行了三次握手，成功建立了连接。

![](https://raw.githubusercontent.com/Bearfu/pic/master/img/20190821164738.png)

既然已经成功的建立了TCP连接，那么下一步，客户端就要准备使用HTTP协议向服务器发送相应的请求了

双击打开这个封包，可以看到是一个比较基础的Get请求。

![](https://raw.githubusercontent.com/Bearfu/pic/master/img/20190821165154.png)

顺便简单的说一下HTTP请求信息的格式：
HTTP请求信息由3部分组成： 
（1）请求方法URI协议/版本 
（2）请求头(Request Header) 
（3）请求正文 
请求头相关字段代表的内容就不多解释了。
唯一值得一说的是 Upgrade-Insecure-Requests: 1
这个指令用于让浏览器自动升级请求从http到https,用于大量包含http资源的http网页直接升级到https而不会报错.
简单的来讲,相当于在http和https之间起的一个过渡作用.

发起了HTTP请求 我们自然需要获取到服务器的返回值，继续往下看HTTP请求，看到了服务端返回的响应（包 26）

![](https://raw.githubusercontent.com/Bearfu/pic/master/img/20190821172605.png)

HTTP应答与HTTP请求相似，HTTP响应也由3个部分构成，分别是： 
（1）协议状态版本代码描述 
（2）响应头(Response Header) 
（3）响应正文 

协议状态代码描述HTTP响应的第一行类似于HTTP请求的第一行，它表示通信所用的协议是HTTP1.1服务器已经成功的处理了客户端发出的请求（200表示成功）: 
HTTP/1.1 200 OK 

响应头(Response Header)响应头也和请求头一样包含许多有用的信息，例如服务器类型、日期时间、内容类型和长度等

那这里再关注一下响应头，之后在模拟返回首页的时候需要作为参数返回回来。

最后的响应正文明显是一个HTML的文件，但是只有这个是不能正确的渲染网页的。
包的底部我们能看到
[Next request in frame: 26]
那我们就跳转到 包26 看获取到什么

![](https://raw.githubusercontent.com/Bearfu/pic/master/img/20190821174609.png)

可以看到这边是发起了一个获取CSS文件的请求。
嗯 那就可以对格式进行渲染了。
依次往下观察。可以看到同样适用与后续发起的HTTP请求获取 网站的图片和 icon。

最后这些资源会根据HTML的架构在网页中渲染出成品的网页。

那么 关闭连接在哪呢？

观察了一下抓到的包列表，相关包在获取到最后一个资源的时候戛然而止，没有观察到关闭连接的四次挥手。

应该是由于这里建立的是长连接,最后没有关闭连接就直接关闭监控的原因。



# Golang 服务实现
要求是克隆站点的首页返回结果。那就有三个思路。
## 1.最简单的静态页面
可以通过浏览器获取到网页的静态HTML结构，CSS文件，和首页相关的图片资源，可以简单的搭建一个静态页面服务出来。
唯一的附加要求是HTTP层结果一致。
这个我们可以根据原始的HTTP响应头中附带的信息。手动写入到我们服务的响应中即可。缺点是页面是写死的。不能跟随原始网页的数据更新而更新。

## 2.网络转发
这种也是暴力方法，是通过获取到接口请求的时候根据接口请求的内容在服务器后台转发到目标网站。然后将目标网站的返回内容转发给用户。优点是页面能够跟随原始网页变化来进行响应。单由于是做了一次网络转发网页响应的时间就要打折扣了。而且网站的可用性也是基于在原始网站的基础上的。

## 3.完整爬取建站
经过观察，目标网站是一个定期更新的镜像资源网站。原理上可以通过编写单站爬虫，获取所有镜像网址写入数据库。然后转发下载地址的方式完成全站克隆。
具体流程有些复杂。这里就不编写了。

# 压力测试
使用MAC 自带的Ab对已经实现的两个服务进行压力测试，

## 使用静态文件方案的报告
MacBook-Pro:alliance fuzhe$ ab -n 60000 -c 15 -q http://127.0.0.1:8081/
This is ApacheBench, Version 2.3 <$Revision: 1826891 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 127.0.0.1 (be patient).....done


Server Software:        nginx/1.10.2
Server Hostname:        127.0.0.1
Server Port:            8081

Document Path:          /
Document Length:        7472 bytes

Concurrency Level:      15
Time taken for tests:   127.737 seconds
Complete requests:      60000
Failed requests:        0
Total transferred:      462060000 bytes
HTML transferred:       448320000 bytes
Requests per second:    469.72 [#/sec] (mean)
Time per request:       31.934 [ms] (mean)
Time per request:       2.129 [ms] (mean, across all concurrent requests)
Transfer rate:          3532.50 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0   30 714.6      1   19569
Processing:     0    2   1.2      2      54
Waiting:        0    1   0.9      1      50
Total:          0   32 714.6      2   19570

Percentage of the requests served within a certain time (ms)
  50%      2
  66%      3
  75%      3
  80%      3
  90%      4
  95%      4
  98%      6
  99%      7
 100%  19570 (longest request)

## 使用网址转发的报告
MacBook-Pro:alliance fuzhe$ ab -n 30000 -c 15 -q http://127.0.0.1:8082/
This is ApacheBench, Version 2.3 <$Revision: 1826891 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 127.0.0.1 (be patient).....done


Server Software:
Server Hostname:        127.0.0.1
Server Port:            8082

Document Path:          /
Document Length:        0 bytes

Concurrency Level:      15
Time taken for tests:   51.417 seconds
Complete requests:      30000
Failed requests:        0
Non-2xx responses:      30000
Total transferred:      3750000 bytes
HTML transferred:       0 bytes
Requests per second:    583.47 [#/sec] (mean)
Time per request:       25.708 [ms] (mean)
Time per request:       1.714 [ms] (mean, across all concurrent requests)
Transfer rate:          71.22 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0   25 622.9      1   19536
Processing:     0    1   0.5      1      15
Waiting:        0    1   0.4      1      15
Total:          0   26 622.9      2   19537

Percentage of the requests served within a certain time (ms)
  50%      2
  66%      2
  75%      2
  80%      2 
  90%      3
  95%      3
  98%      4
  99%      4
 100%  19537 (longest request)

# 服务优化
1
 









