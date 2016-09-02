#!/bin/bash

dbuser="root"
dbpwd=`cat /data/save/mysql_root`

if [[ $# -lt 3 ]]; then
    echo "Usage like: $0 db1 db2_old db3 ..."
    exit 1
fi

agent=`echo $1 | awk -F_ '{print $2}'`
log_file="/data/logs/${agent}_log_db.log"
check=`echo $2 | awk -F_ '{print $NF}'`
new_date=`date +"%F %T"`
echo "================${new_date}================" | tee -a ${log_file}

if [ "$check" == "old" ] ; then
	#list=$@
	#echo $list

	#totle=$#
	#echo $totle
	all=`mysql -u$dbuser -p$dbpwd $1 -s -e "select count(*) from t_log_pay;" | sed -n '$p';`
	shift
	totle=0
	for db in $@ ;do
		#mysql -u$dbuser -p$dbpwd $db  -s -e "flush tables;"
		pay_num=`mysql -u$dbuser -p$dbpwd $db -s -e "select count(*) from t_log_pay;" | sed -n '$p';`
		echo "$db -- > $pay_num" | tee -a ${log_file}
		totle=$((totle + pay_num))
	done
	echo -e "\n原游戏服 t_log_pay 总记录为 : $totle" | tee -a ${log_file}
	
	if [[ $all == $totle ]] ;then
		#echo "" | tee -a ${log_file}
		echo "合并数据表 t_log_pay 正常,总记录 : $all" | tee -a ${log_file}
	else
		echo -e "\t\t合并数据出错了.....,总记录只有 : $$all" | tee -a ${log_file}
	fi
else
	echo "Usage error , Usage like: $0 db1 db2_old db3 ... "
	exit 1

fi
echo "================END================" | tee -a ${log_file}
