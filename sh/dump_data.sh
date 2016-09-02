#!/bin/bash

if [[ "$1" == "" ]] ;then
    echo "usage : sh $0 8090"
    exit 1
fi

agent=$1
dbuser="root"
dbpwd=`cat /data/save/mysql_root`
pro_agent="D5_${agent}_admin1"
dbs=`mysql -u${dbuser} -p${dbpwd} -e "show databases;" | grep "_${agent}_"`

for db in $dbs ;do
    echo $db
    mysqldump -u${dbuser} -p${dbpwd} ${db} > ${db}.sql
done
