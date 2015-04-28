FROM tutum/lamp:latest
# VOLUME /var/lib/mysql
ADD deploy/apache-vhost-for-static /etc/apache2/sites-available/001-static.conf
RUN a2ensite 001-static

ADD deploy /deploy
ADD . /srv/datawrapper/
RUN rm -fr /app && \
	ln -s /srv/datawrapper/www /app && \
	cd /srv/datawrapper/ && \
	php /deploy/composer_install.php && \
	php composer.phar install &&\
	chmod +x /deploy/*.sh
RUN apt-get update &&\
	apt-get install -y phantomjs php5-curl nullmailer
EXPOSE 80 3306

CMD ["bash","/deploy/develop_run.sh"]