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

# loading plugins requires database to be up so we do it hre
php scripts/plugin.php install "admin*"
php scripts/plugin.php install "core*"
php scripts/plugin.php install "phantomjs"
php scripts/plugin.php install "email-native" # req'd for export-image
php scripts/plugin.php install "export*"
php scripts/plugin.php install "gallery"
php scripts/plugin.php install "publish-s3"
php scripts/plugin.php install "theme-default"
php scripts/plugin.php install "theme-dive*"
php scripts/plugin.php install "visualization"
php scripts/plugin.php install "visualization-raphael-chart" # req'd for bar chart
php scripts/plugin.php install "visualization-bar-chart"
php scripts/plugin.php install "visualization-column-chart"
php scripts/plugin.php install "visualization-line-chart"


echo "=> Datawrapper Plugins Loaded"

mysqladmin -uroot shutdown