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

check_instance(){
  local instance_id=$1
  if [[ ${instance_id} = "i-0f488af9d15dd891c" ]]; then # データ収集用のインスタンス
    return 0;    
  elif [[ ${instance_id} = "i-09c7895d018cd7908" ]]; then # GMO_Data
    return 0;
  else
    return 1;
  fi  
}

send_message "start checking" logs
for instance_id in $(list_instances); do
  echo ${instance_id}
  if ! check_instance ${instance_id}; then
    send_message "<@hotoku> ${instance_id} is running" warns
  fi
done
