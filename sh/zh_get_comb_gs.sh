#!/bin/bash

#此脚本用来合服时,获取 comb_config.bash 配置文件中的 comb_sers 变量
 
#使用方法
if [[ "$3" == "" ]]; then
    echo -e "\tUsage error...\n\tUsage like : sh $0 8090 1 20"
    exit 1
fi

#判断本机mysql服务是否启动
mysql_up=`netstat -ntpl | grep mysql`
if [[ ${mysql_up} == "" ]] ;then
    echo "mysqld not running ,please check it ,exit..."
    exit 6
fi

#传递的3个参数分别赋值
agent_alias=$1
min_id=$2
max_id=$3

#判断本机是否符合执行脚本条件，本机需只有该平台一个管理后台，大于1将退出脚本
admin_num=`ls -d /data/games/*${agent_alias}_admin* 2>/dev/null | wc -l`
if [[ ${admin_num} -ne 1 ]] ;then
    echo -e "\tThe server has D5_${agent_alias}_admin more than 1 , or input the first parameter has some error , please check it, exit..."
    exit 3
fi

agent=`ls -d /data/games/D5_${agent_alias}_admin* 2>/dev/null | awk -F[\/] '{print $NF}' | sed -n "$"p`

# get agent admin dbuser dbpwd
if [[ -d /data/games/${agent}/gameadmin/ ]]; then
    dbuser=`awk -F\' '/user/{print $4}' /data/games/${agent}/gameadmin/protected/config/config.db.php`
    dbpwd=`awk -F\' '/passwd/{print $4}' /data/games/${agent}/gameadmin/protected/config/config.db.php`
    db=`awk -F\' '/dbname/{print $4}' /data/games/${agent}/gameadmin/protected/config/config.db.php`
else
    echo "admin ${agent} Not Find ,Exit...."
    exit 2
fi

# 判断是否能获取到平台id号，获取为空将退出脚本
#agent_id=`awk -F[\,,\),\ ] '/PROXYID/{print $3}' /data/games/${agent}/gameadmin/protected/config/config.php`
agent_id=`awk -F[\,,\)] '/PROXYID/{print $2}' /data/games/${agent}/gameadmin/protected/config/config.php | sed "s# ##g"`
if [[ ${agent_id} == "" ]] ;then
    echo "Get agent id fail , please check , exit..."
    exit 4
else
    echo -e "\t${agent_alias} agent id is : ${agent_id}"
fi

# 重新处理 min_id ，即是合服时最小的服
if [[ ${min_id} -ge 1 ]] && [[ ${min_id} -le 9 ]] ;then
    min_id="0000${min_id}"
elif [[ ${min_id} -ge 10 ]] && [[ ${min_id} -le 99 ]] ;then
    min_id="000${min_id}"
elif [[ ${min_id} -ge 100 ]] && [[ ${min_id} -le 999 ]] ;then
    min_id="00${min_id}"
elif [[ ${min_id} -ge 1000 ]] && [[ ${min_id} -le 9999 ]] ;then
    min_id="0${min_id}"
else
    min_id=""   #这里暂不处理大于9999之后的服
    echo "min_id has some error,please check it...."
fi

# 重新处理 max_id ，即是合服时最大的服
if [[ ${max_id} -ge 1 ]] && [[ ${max_id} -le 9 ]] ;then
    max_id="0000${max_id}"
elif [[ ${max_id} -ge 10 ]] && [[ ${max_id} -le 99 ]] ;then
    max_id="000${max_id}"
elif [[ ${max_id} -ge 100 ]] && [[ ${max_id} -le 999 ]] ;then
    max_id="00${max_id}"
elif [[ ${max_id} -ge 1000 ]] && [[ ${max_id} -le 9999 ]] ;then
    max_id="0${max_id}"
else
    max_id=""   #这里暂不处理大于9999之后的服
    echo "max_id has some error,please check it...."
fi

# 赋值最小服id和最大服id
if [[ "${min_id}" == "" ]] || [[ "${max_id}" == "" ]] ;then
    echo "get gs_id fail , exit..."
    exit 5
else
    min_id="${agent_id}${min_id}"
    max_id="${agent_id}${max_id}"
    mysql -u${dbuser} -p${dbpwd} -s -e "select dbname,url from ${db}.t_server_config where iscombine = 0 and id >= ${min_id} and id <= ${max_id};" | sort -n | sed s#http\:\/\/## | sed s#\:[[:digit:]][[:digit:]]\/## | awk '{print "[\""$1"\"]=""\""$2"\""}'
fi

    #available 1:可用 0:不可用 (同步日志使用)
    #iscombine 1:已合服 0:未合服 (别名在标题上是否显示)
