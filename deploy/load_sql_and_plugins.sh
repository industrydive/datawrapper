#!/bin/bash
cd /srv/datawrapper/

/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

cat /deploy/setup_db.sql /srv/datawrapper/lib/core/build/sql/schema.sql /deploy/autoload_*.sql | mysql -uroot

echo "=> Inital SQL Loaded"

# loading plugins requires database to be up
php scripts/plugin.php install "*"

echo "=> Datawrapper Plugins Loaded"

mysqladmin -uroot shutdown