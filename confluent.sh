#!/bin/bash

# resolve links - $0 may be a softlink
PRG="$0"

while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

# Get standard environment variables
PRGDIR=`dirname "$PRG"`

PROJECT_DIR=`cd "$PRGDIR/.." >/dev/null; pwd`
#echo PROJECT_DIR=$PROJECT_DIR

BASE_DIR="~/confluent-cloud/"
confluent_VERSION="confluent-2.0.1"

usage() {
  echo >&2 "Usage: $PRG <command> [args]"
  echo 'Valid commands: install, start, status, stop, deldata, delall'
  exit 1
}

install() {
    for i in `cat ips`;
    do
        echo $i": install ...";
        scp -r confluent-cloud $i:~/;
    done;
}

start() {
    for i in `cat ips`;
    do
        echo $i": start ...";
        ssh $i "cd confluent-cloud/"$confluent_VERSION";bin/kafka-server-start etc/kafka/server.properties &" &
        sleep 5s;
    done;
}

status() {
    for i in `cat ips`;
    do
        echo $i": status ...";
        ssh $i "ps aux | grep SupportedKafka | grep -v grep";
    done;
}

stop() {
    for i in `cat ips`;
    do
        echo $i": stop ...";
        ssh $i "cd confluent-cloud/"$confluent_VERSION";bin/kafka-server-stop &" &
        sleep 5s;
    done;
}

deldata() {
    for i in `cat ips`;
    do
        echo $i": deldata ...";
        ssh $i "rm -r "$BASE_DIR"kafka-logs";
    done;
}

delall() {
    for i in `cat ips`;
    do
        echo $i": delall ...";
        ssh $i "rm -r "$BASE_DIR;
    done;
}

case $1 in
    (install)
        shift
        install $@
        ;;
    (start)
        start
        ;;
    (status)
        shift
        status $@
        ;;
    (stop)
        shift
        stop $@
        ;;
    (deldata)
        shift
        deldata $@
        ;;
    (delall)
        shift
        delall $@
        ;;
    (*)
        echo >&2 "$PRG: error: unknown command '$1'"
        usage
        ;;
esac
