#!/bin/bash

BASEDIR=`pwd`

postgres() {
# Removing old versions

/etc/init.d/postgresql-9.1 stop
killall pgpool
rm /etc/init.d/postgresql*
rm -rf /dados/*
rm -rf /usr/local/pgsql*
rm /usr/local/bin/*
rm -rf /usr/local/etc/*
cp .bashrc /root/
cp .bashrc /home/postgres/
> /etc/profile
> /etc/enviroment
/etc/init.d/heartbeat stop
rm -rf /etc/ha.d
rm -rf /usr/lib/heartbeat*
rm -rf /usr/lib/ocf
rm -rf /var/lib/heartbeat
cp $BASEDIR/sources.list /etc/apt/
apt-get update

# Install Postgres 9.3

su - <<EOF
cd /usr/local/src
wget http://ftp.postgresql.org/pub/source/v9.3.4/postgresql-9.3.4.tar.gz
tar zxvf postgresql-9.3.4.tar.gz
cd postgresql-9.3.4
./configure --prefix=/usr/local/pgsql9.3.4
make
make install
ln -s /usr/local/pgsql9.3.4 /usr/local/pgsql
cd /etc/init.d/
cp $BASEDIR/postgresql-9.3 .
update-rc.d postgresql-9.3 defaults
chown postgres:postgres -R /dados
echo "PATH=/usr/local/pgsql/bin:$PATH" >> /etc/profile
EOF

su - postgres <<EOF
initdb -D /dados/postgresql
mkdir /dados/log
mkdir /dados/config
EOF

cp $BASEDIR/postgresql.conf /dados/postgresql/
cp $BASEDIR/pg_hba.conf /dados/postgresql/
cp $BASEDIR/log.conf /dados/config/
cp $BASEDIR/replicacao.conf /dados/config/

chown postgres:postgres -R /dados/config/
chown postgres:postgres /dados/postgresql/*.conf

/etc/init.d/postgresql-9.3 start
}

# Install PgpoolII

pgpool() {
source /etc/profile
cd /usr/local/src
wget http://www.pgpool.net/mediawiki/images/pgpool-II-3.3.3.tar.gz
tar zxvf pgpool-II-3.3.3.tar.gz
cd pgpool-II-3.3.3
./configure
make
make install
cd sql/pgpool-regclass
make
make install
psql -U postgres template1 -c "CREATE EXTENSION pgpool_regclass"
echo "pgpool.pg_ctl = '/usr/local/pgsql/bin/pg_ctl'" >> /dados/postgresql/postgresql.conf
/etc/init.d/postgresql-9.3 reload
cp $BASEDIR/pgpool.conf /usr/local/etc/
cp $BASEDIR/pcp.conf /usr/local/etc/
cp $BASEDIR/failover.sh /usr/local/etc/
cp $BASEDIR/pgpool /etc/init.d/
mkdir /var/run/pgpool
mkdir /var/log/pgpool
chown postgres:postgres -R /var/run/pgpool
chown postgres:postgres -R /var/log/pgpool
update-rc.d pgpool defaults
}

case "$1" in
	postgres)
		postgres
	;;
	pgpool)
		pgpool
	;;
        *)
	echo "Usage: $0 {postgres|pgpool}"
	exit 7
esac

exit 0
