#!/bin/bash
# restart docker
#2020-07-23 Guanwf

log() {
  DATE=$(date +'%F-%H%M%S')
  message="$DATE $1";
  echo $message
  echo $message >> log.log
}

log "docker restart"

systemctl restart docker
