#!/bin/bash

# Variaveis de ambiente

MASTER=postgresql01
USER=postgres
PORT=5432
DBNAME=postgres
BINDIR=/usr/local/pgsql/bin
PGDATA=/dados/postgresql

$BINDIR/pg_ctl -D $PGDATA stop -mi > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "PostgreSQL ja esta parado."
fi

# Backup

rm -rf $PGDATA

$BINDIR/pg_basebackup -D $PGDATA -R -P -h $MASTER

# Restauracao

sed -i 's/#hot_standby = off/hot_standby = on/g' $PGDATA/../config/replicacao.conf

$BINDIR/pg_ctl -D $PGDATA start

if [ $? -eq 0 ]; then
  echo "Backup finalizado com sucesso!"
fi
