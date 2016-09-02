#!/bin/bash

function del_old(){
    cd ${base_dir}
    alldirs=$(find -type d -regextype posix-egrep -regex '.*/[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}')

    for dir in ${alldirs}; do
        if [[ $(date -d "$(basename ${dir})" +%s) -le $(date -d '-7 day 00:00:00' +%s) ]]; then
            # echo ${dir}
            rm -rf ${dir}
        fi
    done
}

function get_lst(){
    cd ${sh_dir} && rm -f qq_allgs_*lst
    if ! lftp -u app1103117549,d1tjSWT697PyhO8W cvmftp.tencentyun.com:53000 -e "get ${lst};quit"; then
        echo "fail to get ${lst}"
        exit 1
    fi
}

function get_db(){
    gs=$1
    gs_ip=$2
    port=$3

    l_path="${base_dir}/${gs}/$(date +%Y-%m-%d)"
    test -d ${l_path} || mkdir -p ${l_path}
    r_path="/data/backup/mongodb/${gs}/$(date +%Y-%m-%d)"

    newest=$(ssh -n -p ${port} -o StrictHostKeyChecking=no ${gs_ip} "cd ${r_path} && ls -1t | /bin/grep -m 1 '^${gs}'")
    if [[ ! ${newest} == "" ]]; then
        r_md5=$(ssh -n -p ${port} -o StrictHostKeyChecking=no ${gs_ip} "md5sum ${r_path}/${newest} | awk '{print \$1}'")
        if [[ -f ${l_path}/${newest} ]]; then
            l_md5=$(md5sum ${l_path}/${newest} | awk '{print $1}')
            if [[ ! "${r_md5}" == "${l_md5}" ]]; then scp -P ${port} -o StrictHostKeyChecking=no ${gs_ip}:${r_path}/${newest} ${l_path}; fi
        else
            scp -P ${port} -o StrictHostKeyChecking=no ${gs_ip}:${r_path}/${newest} ${l_path}
            l_md5=$(md5sum ${l_path}/${newest} | awk '{print $1}')
        fi
        if [[ ! "${r_md5}" == "" ]] && [[ "${r_md5}" == "${l_md5}" ]]; then
            echo "get ${newest} success"
        else
            echo "get ${newest} fail"
        fi
    else
        echo "fail: no backup available"
    fi
}

lst="qq_allgs_$(date +%Y%m%d).lst"
sh_dir=$(cd $(dirname $0) && pwd)
base_dir="/data/center_backup/mongodb"
mkdir -p ${base_dir}
# 删除7天前的备份
del_old
# 获取服务器列表
#get_lst
cd ${sh_dir}
while read line; do
    get_db ${line}
done<${lst}
