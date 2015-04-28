#!/bin/bash

# a forked version of https://github.com/tutumcloud/tutum-docker-lamp/blob/master/run.sh
# that calls the load_sql.sh script as well

VOLUME_HOME="/var/lib/mysql"

# This is for development
cd /srv/datawrapper &&\
	php /deploy/composer_install.php &&\
	php composer.phar install

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"  
    /create_mysql_admin_user.sh
    /deploy/load_sql_and_plugins.sh
else
    echo "=> Using an existing volume of MySQL"
fi

# hack/fix permissions for datawrapper
chmod -R 777 /srv/datawrapper/charts/static /srv/datawrapper/charts/data \
	/srv/datawrapper/charts/images /srv/datawrapper/charts/data/tmp /srv/datawrapper/tmp

# hack for owning folder permissions by apache
usermod -u 1000 www-data

rm /srv/datawrapper/www/static/

exec supervisord -n