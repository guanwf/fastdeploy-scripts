#!/bin/bash
#docker install
#2020-07-27 Guanwf
#2021-03-18 Guanwf 调整版本docker-24.0.9

#注意：
# 1、
#如果dockerimage需要变更存放路径，则需要修改这个路径
# /home/docker/docker/dockerimage
# 2、
# 采用docker用户进行安装
#

#su docker

ENV_CFG=./env.cfg
if [ -f ${ENV_CFG} ] ; then
	chmod 777 ${ENV_CFG}
	source ${ENV_CFG}
fi

log() {
  DATE=$(date +'%F-%H%M%S')
  message="$DATE $1";
  echo $message
  echo $message >> log.log
}

if [ ! -f "docker-24.0.9.tgz" ];then
  log "docker-24.0.9.tgz file not exists."
  exit 1;
fi

#设置变量
if ! grep -q "^export DOCKER_HOME=" /etc/profile; then
  echo "export DOCKER_HOME=${DOCKER_HOME}" >> /etc/profile
fi

DOCKER_DATAPATH=${DOCKER_HOME}/docker/dockerimage
if [ ! -d "${DOCKER_DATAPATH}" ];then
  mkdir -p ${DOCKER_DATAPATH}
fi

#mkdir -p ${DOCKER_HOME}/docker/dockerimage
mkdir -p /etc/docker

chown -R docker:dockergroup ${DOCKER_HOME}

log "docker install..."

#if [ ! -f "/etc/yum.repos.d/docker-ce.repo" ];then
#   #wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo
#   cp -f -R ../config/docker-ce.repo /etc/yum.repos.d/docker-ce.repo
#fi

#https://download.docker.com/linux/static/stable/x86_64/docker-24.0.9.tgz

if [ ! -f "./docker-24.0.9.tgz" ];then
  wget https://download.docker.com/linux/static/stable/x86_64/docker-24.0.9.tgz
  tar -zxvf docker-24.0.9.tgz -C ../
  cp ../docker/* /usr/bin/
else
  log "docker-24.0.9.tgz file is exists."
fi

tar -zxvf docker-24.0.9.tgz -C ../
cp ../docker/* /usr/bin/

if [ ! -f "/etc/docker/daemon.json" ];then

log "create /etc/docker/daemon.json file"

cat <<EOF > /etc/docker/daemon.json
{
  "log-driver":"json-file",
    "registry-mirrors": [
    "https://hub-mirror.c.163.com",
    "https://dist7hw1.mirror.aliyuncs.com",
    "http://4a1df5ef.m.daocloud.io",
    "https://mirror.baidubce.com"
  ],
  "data-root": "${DOCKER_DATAPATH}",
  "log-opts": {"max-size":"1024m", "max-file":"3"}

}
EOF

fi

if [ ! -f "/usr/lib/systemd/system/docker.service" ];then

log "create docker.service /usr/lib/systemd/system/docker.service file"

cat <<EOF > /usr/lib/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd
ExecReload=/bin/kill -s HUP $MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
# restart the docker process if it exits prematurely
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target
EOF

chmod +x /usr/lib/systemd/system/docker.service

systemctl enable docker.service

systemctl daemon-reload

systemctl start docker

else
  systemctl restart docker

fi

#id=`ps x |grep docker |awk '{ print $1 }'`
