#!/bin/sh

# INICIO EDIÇÃO:

# Interface de rede a associar ao VIP
iface=eth0
# Último octeto do VIP (p.e. se IP da máquina for 192.168.1.X e master_sub_ip=200 então master_vip=192.168.1.200)
master_sub_ip=200

# FIM EDIÇÃO


basedir=$(dirname $0)
# Recupera IP e máscara
inet_addr=$(ip -oneline -family inet addr show ${iface} | head -n1 | awk '{print $4}')
ip=$(echo ${inet_addr} | awk -F '/' '{print $1}')
netmask=$(echo ${inet_addr} | awk -F '/' '{print $2}')
master_ip=$(echo ${ip} | awk -F '.' '{printf("%d.%d.%d.'${master_sub_ip}'", $1, $2, $3)}')
bind_addr=$(echo ${ip} | awk -F '.' '{printf("%d.%d.%d.0", $1, $2, $3)}')

set -x

apt-get install -y pacemaker corosync

cp "${basedir}/corosync.conf" /etc/corosync/corosync.conf
sed -i 's/\(bindnetaddr:\).*/\1 '${bind_addr}'/' /etc/corosync/corosync.conf
sed -i 's/START=.*/START=yes/' /etc/default/corosync
cp "${basedir}/pgsr" /usr/lib/ocf/resource.d/heartbeat/pgsr

