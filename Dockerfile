FROM tutum/lamp:latest
# VOLUME /var/lib/mysql
ADD deploy/apache-vhost-for-static /etc/apache2/sites-available/001-static.conf
ADD deploy/supervisord-executejobs.conf /etc/supervisor/conf.d/supervisord-executejobs.conf
ADD deploy /deploy
RUN apt-get update -qq &&\
	apt-get install -qq -y phantomjs php5-curl nullmailer nano
ADD . /srv/datawrapper/
RUN rm -fr /app && \
	ln -s /srv/datawrapper/www /app && \
	cd /srv/datawrapper/ && \
	php /deploy/composer_install.php && \
	php composer.phar install &&\
	a2ensite 001-static &&\
	chmod +x /deploy/*.sh &&\
	echo "127.0.0.1  www.datawrapper.local" >> /etc/hosts &&\
	echo "127.0.0.1  static.datawrapper.local" >> /etc/hosts &&\
	echo "OK"
RUN mkdir -p /srv/datawrapper/tmp && \
	chown -R www-data /srv/datawrapper && \
	chmod -R 777 /srv/datawrapper/charts/static /srv/datawrapper/charts/data && \
    chmod -R 777 /srv/datawrapper/charts/images /srv/datawrapper/charts/data/tmp /srv/datawrapper/tmp && \
	chmod -R 777 /srv/datawrapper/vendor/htmlpurifier/standalone/HTMLPurifier/DefinitionCache/Serializer
EXPOSE 80 3306

CMD ["bash","/deploy/production_run.sh"]