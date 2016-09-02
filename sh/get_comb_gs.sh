#!/bin/bash

#How to Usage 
if [[ "$3" == "" ]]; then
    echo -e "\tUsage error...\n\tUsage like : sh $0 8090 1 20"
    exit 1
fi

agent_alias=$1
min_id=$2
max_id=$3
agent=`ls -d /data/games/D5_${agent_alias}_admin* | awk -F[\/] '{print $NF}' | sed -n "$"p`

admin_num=`ls -d /data/games/${agent} | wc -l`
if [[ ${admin_num} -ne 1 ]] ;then
    echo -e "\tThe server has D5_${agent}_admin more than 1 , has some error , exit..."
    exit 3
fi

# get agent admin dbuser dbpwd
if [[ -d /data/games/${agent}/gameadmin/ ]]; then
    dbuser=`awk -F\' '/user/{print $4}' /data/games/${agent}/gameadmin/protected/config/config.db.php`
    dbpwd=`awk -F\' '/passwd/{print $4}' /data/games/${agent}/gameadmin/protected/config/config.db.php`
    db=`awk -F\' '/dbname/{print $4}' /data/games/${agent}/gameadmin/protected/config/config.db.php`	
else
    echo "admin ${agent} Not Find ,Exit...."
    exit 2
fi

agent_id=`awk -F[\,,\)] '/PROXYID/{print $2}' /data/games/${agent}/gameadmin/protected/config/config.php | sed "s# ##g"`
if [[ ${agent_id} == "" ]] ;then
    echo "Get agent id fail , please check , exit..."
    exit 4
else
        echo -e "\t${agent_alias} agent id is : ${agent_id}"
fi

if [[ ${min_id} -ge 1 ]] && [[ ${min_id} -le 9 ]] ;then
    min_id="0000${min_id}"
elif [[ ${min_id} -ge 10 ]] && [[ ${min_id} -le 99 ]] ;then
    min_id="000${min_id}"
elif [[ ${min_id} -ge 100 ]] && [[ ${min_id} -le 999 ]] ;then
    min_id="00${min_id}"
elif [[ ${min_id} -ge 1000 ]] && [[ ${min_id} -le 9999 ]] ;then
    min_id="0${min_id}"
else
    echo "min_id has some error,please check it...."
fi

if [[ ${max_id} -ge 1 ]] && [[ ${max_id} -le 9 ]] ;then
    max_id="0000${max_id}"
elif [[ ${max_id} -ge 10 ]] && [[ ${max_id} -le 99 ]] ;then 
    max_id="000${max_id}"
elif [[ ${max_id} -ge 100 ]] && [[ ${max_id} -le 999 ]] ;then
    max_id="00${max_id}"
elif [[ ${max_id} -ge 1000 ]] && [[ ${max_id} -le 9999 ]] ;then
    max_id="0${max_id}"
else
    echo "max_id has error...."
fi

if [[ "${min_id}" == "" ]] && [[ "${max_id}" == "" ]] ;then
    echo "get gs_id fail , exit..."
    exit 5
else
    min_id="${agent_id}${min_id}"
    max_id="${agent_id}${max_id}"
    mysql -u${dbuser} -p${dbpwd} -s -e "select dbname,url from ${db}.t_server_config where iscombine = 0 and id >= ${min_id} and id <= ${max_id};" | sort -n | sed s#http\:\/\/## | sed s#\:[[:digit:]][[:digit:]]\/## | awk '{print "[\""$1"\"]=""\""$2"\""}'
fi

    #available 1:available   0: not available
    #iscombine 1:combine     0: not combine 
