#!/usr/bin/env bash
. ./tools/CONSTANTS
. /etc/profile
#hadoop_env.sh
HADOOP_CONF_DIR=$APP_HOME/hadoop/etc/hadoop
SPARK_CONF_DIR=$SPARK_HOME/conf
echo "export JAVA_HOME=$JAVA_HOME" > $HADOOP_CONF_DIR/hadoop-env.sh
. $HADOOP_CONF_DIR/hadoop-env.sh
echo "export JAVA_HOME=$JAVA_HOME" > $HADOOP_CONF_DIR/yarn-env.sh
echo "export JAVA_HOME=$JAVA_HOME
export SCALA_HOME=$APP_HOME/scala
export HADOOP_HOME=$HADOOP_HOME
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export SPARK_MASTER_IP=$MASTER_IP
export SPARK_MASTER_HOST=$MASTER
export SPARK_HOME=$SPARK_HOME
export SPARK_DIST_CLASSPATH=$($HADOOP_HOME/bin/hadoop classpath)" > $SPARK_CONF_DIR/spark-env.sh
. $SPARK_CONF_DIR/spark-env.sh
#cores-site.xml
echo "<configuration>
   <property>
       <name>fs.defaultFS</name>
       <value>hdfs://$MASTER:9000</value>
   </property>
  <property>
       <name>hadoop.tmp.dir</name>
       <value>$HADOOP_HOME/tmp</value>
  </property>
</configuration>" > $HADOOP_CONF_DIR/core-site.xml
#hdfs-site.xml
echo "<configuration>
 <property>
   <name>dfs.http.address</name>
   <value>$MASTER:50070</value>
 </property>
 <property>
   <name>dfs.replication</name>
   <value>$REPLICATION</value>
 </property>
 <property>
   <name>dfs.namenode.name.dir</name>
   <value>file://$HADOOP_HOME/tmp/dfs/name</value>
 </property>
 <property>
   <name>dfs.datanode.data.dir</name>
   <value>file://$HADOOP_HOME/tmp/dfs/data</value>
 </property>
</configuration>" > $HADOOP_CONF_DIR/hdfs-site.xml
echo "<configuration>
<property>
 <name>mapreduce.framework.name</name>
 <value>yarn</value>
</property>
</configuration>" > $HADOOP_CONF_DIR/mapred-site.xml
echo "<configuration>
<property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
</property>
<property>
    <name>yarn.resourcemanager.hostname</name>
    <value>$MASTER</value>
</property>
</configuration>" > $HADOOP_CONF_DIR/yarn-site.xml
#spark and hadoop hosts
SLAVES_FILE=$SPARK_CONF_DIR/slaves
WORKERS_FILE=$HADOOP_CONF_DIR/workers
cat /dev/null > $SLAVES_FILE
cat /dev/null > $WORKERS_FILE
for IP in $IPS;do
    [[ $IP != $MASTER_IP ]] && echo ${IP_HOSTS[$IP]} >> $WORKERS_FILE
    echo ${IP_HOSTS[$IP]} >> $SLAVES_FILE
done
for IP in $IPS;do
    ssh $USR@$IP "mkdir -p $HADOOP_HOME/tmp"
    if [[ $IP != $MASTER_IP ]]; then
        for dir_n in $HADOOP_CONF_DIR $SPARK_CONF_DIR;do
            rsync -avz $dir_n $USR@$IP:${dir_n%/*}
        done
    fi
done
for IP in $IPS; do
    ssh $USR@$IP "echo SPARK_LOCAL_IP=$IP >> $SPARK_CONF_DIR/spark-env.sh"
done
