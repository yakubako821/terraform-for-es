#!/bin/bash

# ECS config
echo ECS_CLUSTER=${ecs_cluster_name} >> /etc/ecs/ecs.config

# SSM Agent Install
# https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/sysman-manual-agent-install.html#agent-install-rhel
mkdir /tmp/ssm
cd /tmp/ssm
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo start amazon-ssm-agent


# OS Config
cp /etc/localtime /etc/localtime.org
ln -sf  /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
cp /etc/sysconfig/clock /etc/sysconfig/clock.org
sed -i -e "1c\ZONE=\"Asia/Tokyo\"" /etc/sysconfig/clock
service rsyslog restart
service crond restart

mkdir /tmp/ssm
cd /tmp/ssm
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm


# Elasticsearch Config
sysctl -w vm.max_map_count=262144
sysctl -w vm.swappiness=1
sysctl -w net.ipv4.tcp_tw_reuse=1
sysctl -w net.ipv4.tcp_fin_timeout=30
sysctl -p
echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
echo 'vm.swappiness=1' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_tw_reuse=1' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_fin_timeout=30' >> /etc/sysctl.conf

echo 'root soft nofile 1048576' >> /etc/security/limits.conf
echo 'root hard nofile 1048576' >> /etc/security/limits.conf
echo '* soft nofile 1048576' >> /etc/security/limits.conf
echo '* hard nofile 1048576' >> /etc/security/limits.conf
echo '* soft nproc 8192' >> /etc/security/limits.conf
echo '* hard nproc 8192' >> /etc/security/limits.conf
echo '* soft memlock unlimited' >> /etc/security/limits.conf
echo '* hard memlock unlimited' >> /etc/security/limits.conf


# Elasticsearch Data Mount Config
ELASTICSEARCH_DATA_MOUNT_DIR="/usr/share/elasticsearch/data"
ELASTICSEARCH_DATA_MOUNT_DIR_1="$ELASTICSEARCH_DATA_MOUNT_DIR/data1"
ELASTICSEARCH_DATA_MOUNT_DIR_2="$ELASTICSEARCH_DATA_MOUNT_DIR/data2"

#INSTANCE_TYPE=`curl http://169.254.169.254/latest/meta-data/instance-type`
#INSTANCE_FAMILY=`echo $INSTANCE_TYPE | awk -F'[.]' '{print $1}'`

DEVICE_NAME_1="nvme0n1"
DEVICE_NAME_2="nvme1n1"

if [[ `lsblk | grep $DEVICE_NAME_1 | wc -l` -eq 1 && `lsblk | grep $DEVICE_NAME_2 | wc -l` -eq 0 ]]; then
  mkdir -p $ELASTICSEARCH_DATA_MOUNT_DIR
  chmod g+rwx $ELASTICSEARCH_DATA_MOUNT_DIR

  mkfs -t ext4 /dev/$DEVICE_NAME_1
  mount /dev/$DEVICE_NAME_1 $ELASTICSEARCH_DATA_MOUNT_DIR
  echo "/dev/$DEVICE_NAME_1 $ELASTICSEARCH_DATA_MOUNT_DIR    ext4    defaults        0   0" >> /etc/fstab
  chmod g+rwx $ELASTICSEARCH_DATA_MOUNT_DIR
  chgrp 0 $ELASTICSEARCH_DATA_MOUNT_DIR
  cd $ELASTICSEARCH_DATA_MOUNT_DIR

  mkdir $ELASTICSEARCH_DATA_MOUNT_DIR_1 $ELASTICSEARCH_DATA_MOUNT_DIR_2
  chmod g+rwx $ELASTICSEARCH_DATA_MOUNT_DIR_1 $ELASTICSEARCH_DATA_MOUNT_DIR_2
  chgrp 0 $ELASTICSEARCH_DATA_MOUNT_DIR_1 $ELASTICSEARCH_DATA_MOUNT_DIR_2

elif [[ `lsblk | grep $DEVICE_NAME_1 | wc -l` -eq 1 && `lsblk | grep $DEVICE_NAME_2 | wc -l` -eq 1 ]]; then
  mkdir -p $ELASTICSEARCH_DATA_MOUNT_DIR_1 $ELASTICSEARCH_DATA_MOUNT_DIR_2
  chmod g+rwx $ELASTICSEARCH_DATA_MOUNT_DIR_1 $ELASTICSEARCH_DATA_MOUNT_DIR_2
  
  mkfs -t ext4 /dev/$DEVICE_NAME_1
  mount /dev/$DEVICE_NAME_1 $ELASTICSEARCH_DATA_MOUNT_DIR_1
  echo "/dev/$DEVICE_NAME_1 $ELASTICSEARCH_DATA_MOUNT_DIR_1    ext4    defaults        0   0" >> /etc/fstab
  chmod g+rwx $ELASTICSEARCH_DATA_MOUNT_DIR_1
  chgrp 0 $ELASTICSEARCH_DATA_MOUNT_DIR_1

  mkfs -t ext4 /dev/$DEVICE_NAME_2
  mount /dev/$DEVICE_NAME_2 $ELASTICSEARCH_DATA_MOUNT_DIR_2
  echo "/dev/$DEVICE_NAME_2 $ELASTICSEARCH_DATA_MOUNT_DIR_2    ext4    defaults        0   0" >> /etc/fstab
  chmod g+rwx $ELASTICSEARCH_DATA_MOUNT_DIR_2
  chgrp 0 $ELASTICSEARCH_DATA_MOUNT_DIR_2

else
  mkdir -p $ELASTICSEARCH_DATA_MOUNT_DIR_1 $ELASTICSEARCH_DATA_MOUNT_DIR_2
  chmod g+rwx $ELASTICSEARCH_DATA_MOUNT_DIR_1 $ELASTICSEARCH_DATA_MOUNT_DIR_2

fi


# Elasticsearch Logs Mount Config
ELASTICSEARCH_LOGS_MOUNT_DIR="/usr/share/elasticsearch/logs"
mkdir -p $ELASTICSEARCH_LOGS_MOUNT_DIR
chmod g+rwx $ELASTICSEARCH_LOGS_MOUNT_DIR


# Datadog Agent Configuration File
DATADOG_AGENT_CUSTOMIZED_CONF_DIR="/etc/datadog-agent/conf.d/customized.d"
mkdir -p $DATADOG_AGENT_CUSTOMIZED_CONF_DIR
chmod g+rwx $DATADOG_AGENT_CUSTOMIZED_CONF_DIR
echo -e "${datadog_agent_log_config}" > $DATADOG_AGENT_CUSTOMIZED_CONF_DIR/log_conf.yaml
