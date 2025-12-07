#!/bin/bash
#crate docker user
#2020-07-27 Guanwf

#参考：
#新建工作组：groupadd groupname
#将用户添加进工作组：usermod -G groupname username
#useradd
#-d<登入目录> 　指定用户登入时的启始目录。


#root登陆

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

log "create group dockergroup"
groupadd dockergroup

log "create user docker."
if [ ! -d "${DOCKER_HOME}" ];then
  log "mkdir ${DOCKER_HOME}"
  mkdir -p ${DOCKER_HOME}
fi

useradd -g dockergroup docker -d ${DOCKER_HOME} -p abcd1234
#默认工作目录${DOCKER_HOME}

#passwd docker
#设置密码 QWe223

chown -R docker:dockergroup ${DOCKER_HOME}

#usermod -d /home/test3 test
