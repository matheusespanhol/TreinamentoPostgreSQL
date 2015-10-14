#!/bin/sh

# INICIO EDIÇÃO:

# Interface de rede a associar ao VIP
iface=eth4
# Último octeto do VIP (p.e. se IP da máquina for 192.168.1.X e master_sub_ip=200 então master_vip=192.168.1.200)
master_sub_ip=192.168.56.200
netmask=255.255.255.0

# FIM EDIÇÃO

set -x

# Desabilitar STONITH
crm configure property stonith-enabled=false

# Evita troca de recurso desnecessária entre servidores
crm configure rsc_defaults resource-stickiness=100

# Ignora quorum (obrigatório para um cluster de 2 nós)
crm configure property no-quorum-policy=ignore

# Configura IP virtual
crm configure primitive DBIP ocf:heartbeat:IPaddr2 \
    params \
    ip="${master_sub_ip}" cidr_netmask="${netmask}" \
    op monitor interval="30s"

# Configura o PostgreSQL
crm configure primitive pgsql ocf:heartbeat:pgsr \
    params \
    pgctl="/usr/local/pgsql/bin/pg_ctl" \
    psql="/usr/local/pgsql/bin/psql" \
    pgdata="/dados/postgresql" \
    pgdba="postgres" pgport="5432" \
    op monitor interval="30s"

# Força ambos a estarem juntos
crm configure colocation pgsql-with-dbip inf: DBIP pgsql

# Preferência ao postgresql01
crm configure location prefer-master pgsql 100: postgresql01

