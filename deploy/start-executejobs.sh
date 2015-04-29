#!/bin/bash
# called from sueprvisor via supervisord-executejobs.conf 
# to run background jobs for datawrapper
exec /usr/bin/php /srv/datawrapper/scripts/execute_jobs