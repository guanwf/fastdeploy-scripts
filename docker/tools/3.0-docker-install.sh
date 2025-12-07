#!/bin/bash
#docker portainer
#2020-07-29 Guanwf

#注意：
# 1、
#如果dockerimage需要变更存放路径，则需要修改这个路径
# /home/docker/docker/dockerimage
# 2、
# 采用docker用户进行安装
#

log() {
  DATE=$(date +'%F-%H%M%S')
  message="$DATE $1";
  echo $message
  echo $message >> log.log
}

# 下载镜像
log "docker pull docker.io/portainer/portainer"
docker pull docker.io/portainer/portainer

#如果仅有一个docker宿主机，则可使用单机版运行，Portainer单机版运行十分简单，只需要一条语句即可启动容器，来管理该机器上的docker镜像、容器等数据。
#-p: 指定端口映射，格式为：主机(宿主)端口:容器端口

log "run portainer"
docker run -d -p 9000:9000 \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --name portainer-admin \
    portainer/portainer

firewall-cmd --zone=public --add-port=9000/tcp --permanent
#重新载入
firewall-cmd --reload

#http://192.168.2.11:9000
#用户： admin
#密码： abcd1234
