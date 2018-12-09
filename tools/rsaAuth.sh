#!/usr/bin/env bash
. ./tools/CONSTANTS
for IP in $IPS;do
    [[ $IP == $MASTER_IP ]] &&  src_dir=$THIS_DIR/tools || src_dir=$APP_HOME
    expect << eof
    spawn ssh $USR@$IP "rm -rf ~/.ssh; bash $src_dir/toSend/executor.sh $PSWD"
    $EXPECT_CMD
eof
done
#copy pubkey to local host
for IP in $IPS;do
    if [[ $IP != $MASTER_IP ]]; then
        expect << eof
        spawn scp $USR@$IP:~/.ssh/id_rsa.pub $APP_HOME
        $EXPECT_CMD
eof
        cat $APP_HOME/id_rsa.pub >> ~/.ssh/authorized_keys
    else
        cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
    fi
done
chmod 600 ~/.ssh/authorized_keys
#copy full pubkey to other hosts
for IP in $IPS;do
    if [[ $IP != $MASTER_IP ]]; then
        expect << eof
        spawn scp -p /home/$USR/.ssh/authorized_keys $USR@$IP:~/.ssh
        $EXPECT_CMD
eof
    fi
done