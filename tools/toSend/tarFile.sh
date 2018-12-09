#!/usr/bin/env bash
for tfile in `ls $2`;do
    [[ ! -f $2/$tfile ]] && continue
    echo ========" decompressing $tfile "========
    echo `tar -zxvf $2/$tfile -C $1` > /dev/null
    echo ========" decompress complete!"========
done
for dir_name in `ls $1`;do
    [[ -d $1/$dir_name && $dir_name != app && $dir_name != toSend ]]&&mv $1/$dir_name $1/`echo $dir_name|sed -r 's/([a-z]+)[0-9-].*/\1/'`
done