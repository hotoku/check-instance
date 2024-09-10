#!/bin/bash -x

script_dir=$(dirname $(readlink -f $0))
logs_url=$(cat ${script_dir}/credentials/urls.json |jq -r '.logs')
warns_url=$(cat ${script_dir}/credentials/urls.json |jq -r '.warnings')

list_instances(){
  aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query "Reservations[].Instances[].InstanceId" \
    --profile hotoku \
    --output text
}

send_message(){
    local msg=$1
    local dest=$2
    if [[ ${dest} = "logs" ]]
    then
        webhook_url=${logs_url}
    elif [[ ${dest} = "warns" ]]
    then
        webhook_url=${warns_url}
    else
        msg="error: invalid destination. original message: ${msg}"
        webhook_url=${logs_url}
    fi
    local tmp='{"text": "check-instance: __MESSAGE__"}'
    local payload=$(echo ${tmp} | sed -e "s/__MESSAGE__/${msg}/")    
    curl -X POST -H "Content-type: application/json" -d "${payload}" ${webhook_url}
}

send_message "start checking" logs
list_instances | while read instance_id; do
  if [[ ${instance_id} =  "i-0f488af9d15dd891c" ]]; then # データ収集用のインスタンス
    echo "skip"
  else
    send_message "<@hotoku> ${instance_id} is running" warns
  fi
done
