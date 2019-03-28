#!/bin/bash
# Watchdog script to ensure Jenkins CI is awake

JENKINS_PID=`ps -ef | grep jenkins | grep war | awk '{print $2}' | head -1`

if [ -z ${JENKINS_PID} ]; then
  echo "Jenkins is down, restarting"
  systemctl start jenkins
fi


