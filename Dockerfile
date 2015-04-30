FROM tutum/lamp:latest
# VOLUME /var/lib/mysql
ADD deploy/apache-vhost-for-static /etc/apache2/sites-available/001-static.conf
ADD deploy/supervisord-executejobs.conf /etc/supervisor/conf.d/supervisord-executejobs.conf
ADD deploy /deploy
ADD . /srv/datawrapper/
RUN rm -fr /app && \
	ln -s /srv/datawrapper/www /app && \
	cd /srv/datawrapper/ && \
	php /deploy/composer_install.php && \
	php composer.phar install &&\
	a2ensite 001-static &&\
	chmod +x /deploy/*.sh &&\
	echo "127.0.0.1  www.datawrapper.local" >> /etc/hosts &&\
	echo "127.0.0.1  static.datawrapper.local" >> /etc/hosts
RUN apt-get update &&\
	apt-get install -y phantomjs php5-curl nullmailer
EXPOSE 80 3306

CMD ["bash","/deploy/develop_run.sh"]