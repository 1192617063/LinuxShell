#!/usr/bin/env bash
. ./tools/CONSTANTS
sed -i "s/# *IgnoreUserKnownHosts .*/IgnoreUserKnownHosts yes/g" /etc/ssh/sshd_config
sed -i "s/# *PermitRootLogin .*/PermitRootLogin yes/g" /etc/ssh/sshd_config
sed -i "s/# *StrictHostKeyChecking .*/StrictHostKeyChecking no/g" /etc/ssh/ssh_config
echo "127.0.0.1 account.jetbrains.com" > /etc/hosts
cat ./tools/ip_hosts >> /etc/hosts
. /etc/profile
[[ -z $JAVA_HOME ]]&&echo "
export JAVA_HOME=$APP_HOME/jdk
export JRE_HOME=$APP_HOME/jdk/jre
export CLASSPATH=.:$APP_HOME/jdk/lib:$APP_HOME/jdk/jre/lib
export SCALA_HOME=$APP_HOME/scala
export HADOOP_HOME=$APP_HOME/hadoop
export SPARK_HOME=$APP_HOME/spark
export HIVE_HOME=$APP_HOME/hive
export HBASE_HOME=$APP_HOME/hbase
export PATH=$APP_HOME/jdk/bin:$APP_HOME/scala/bin:$APP_HOME/hadoop/bin:$APP_HOME/hadoop/sbin:$APP_HOME/hadoop/lib:$APP_HOME/spark/bin:$APP_HOME/spark/sbin:$APP_HOME/hive/bin:$APP_HOME/hbase/bin:$PATH" >> /etc/profile
for IP in $IPS;do
    expect << eof
    spawn ssh root@$IP "echo ${IP_HOSTS[$IP]} > /etc/hostname;systemctl disable firewalld.service"
    $EXPECT_CMD
eof
    [[ $IP == $MASTER_IP ]] && continue
    for etc_file in ssh/ssh_config ssh/sshd_config profile hosts;do
    expect <<eof
    spawn scp /etc/$etc_file root@$IP:/etc/${etc_file%/*}
    $EXPECT_CMD
eof
    done
done