#!/usr/bin/env bash
. ./tools/CONSTANTS
expect << eof
spawn sudo bash ./tools/editSys.sh
$EXPECT_CMD
eof
for IP in $IPS;do
    expect << eof
    spawn ssh $USR@$IP "mkdir -p $APP_HOME"
    $EXPECT_CMD
eof
    if [[ $IP != $MASTER_IP ]];then
        expect << eof
        spawn scp -rp ./tools/toSend $USR@$IP:$APP_HOME
        $EXPECT_CMD
eof
    fi
done
. ./tools/rsaAuth.sh
for IP in $IPS;do
    echo ==========="ssh on $IP "===========
    [[ $IP == $MASTER_IP ]] && src_dir=$THIS_DIR/tools || src_dir=$APP_HOME
    if [[ $IP != $MASTER_IP ]]; then
    echo $THIS_DIR/tools/app
        scp -rp $THIS_DIR/tools/app $USR@$IP:$APP_HOME
    fi
    ssh $USR@$IP ". $src_dir/toSend/tarFile.sh $APP_HOME $src_dir/app"
done
. ./tools/setEnv.sh
. /etc/profile
hdfs namenode -format