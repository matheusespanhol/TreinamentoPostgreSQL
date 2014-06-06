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

$BINDIR/psql -h $MASTER -U $USER -p $PORT $DBNAME -c "SELECT pg_start_backup('foo')"

rsync -avz --progress --exclude=pg_xlog/* --exclude=pg_xlog/archive_status/* $MASTER:$PGDATA/ $PGDATA/

$BINDIR/psql -h $MASTER -U $USER -p $PORT $DBNAME -c "SELECT pg_stop_backup()"

# Restauracao

rm $PGDATA/*.pid

echo "Criando arquivo recovery.conf..."
echo "
standby_mode = 'true'
primary_conninfo = 'host=postgresql01'
trigger_file = '/tmp/arquivo_gatilho.pgsql'
" > $PGDATA/recovery.conf

sed -i 's/#hot_standby = off/hot_standby = on/g' $PGDATA/postgresql.conf

$BINDIR/pg_ctl -D $PGDATA start

if [ $? -eq 0 ]; then
  echo "Backup finalizado com sucesso!"
fi
