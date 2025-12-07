#!/bin/bash
#2024-05-13

ENV_CFG=./env.cfg
if [ -f ${ENV_CFG} ] ; then
	chmod 777 ${ENV_CFG}
	source ${ENV_CFG}
fi

sh ./1.0-crateuser.sh

sh ./2.0-docker-install-v24-0-9.sh

