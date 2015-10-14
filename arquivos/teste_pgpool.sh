#!/bin/bash

LOOP=10
PGPOOL_SERVER=localhost

for i in $(seq $LOOP)
do 
  psql -h $PGPOOL_SERVER -p 9999 -Atc "SELECT now()" &
done

psql -h $PGPOOL_SERVER -p 9999 -Atc "DROP TABLE IF EXISTS teste"
psql -h $PGPOOL_SERVER -p 9999 -Atc "CREATE TABLE teste(id int)"

for i in $(seq $LOOP)
do
  psql -h $PGPOOL_SERVER -p 9999 -Atc "INSERT INTO teste SELECT generate_series(1,10)" &
done
