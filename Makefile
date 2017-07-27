SHELL=/bin/bash

#	= ^ . ^ =

GIT_REPO_URL=https://github.com/tonejito/nagios3.git

SVC=nagios3
CFG_DIR=/etc/nagios3
CFG_FILE=${CFG_DIR}/nagios.cfg
SHARE_DIR=/usr/share/nagios3
HTDOCS_DIR=${SHARE_DIR}/htdocs
HTTPD_CONF=nagios3.conf

LN=/bin/ln
MV=/bin/mv
RM=/bin/rm
ECHO=/bin/echo
GIT=/usr/bin/git
MKDIR=/bin/mkdir
CHMOD=/bin/chmod
CHGRP=/bin/chgrp
FIND=/usr/bin/find
XARGS=/usr/bin/xargs
A2ENMOD=/usr/sbin/a2enmod
A2ENCONF=/usr/sbin/a2enconf
NAGIOS3=/usr/sbin/nagios3
SERVICE=/usr/sbin/service
APTITUDE=/usr/bin/aptitude

.PHONY:	map

restart:	permissions test
	${SERVICE} ${SVC} restart

permissions:
	${CHMOD} -c  0640  resource.cfg
	${CHGRP} -c nagios resource.cfg

test:	nagios.cfg
	${NAGIOS3} --verify-config ${CFG_FILE}

deps:	deps-apt clone map logos apache-cfg

clone:
	${MV} $(CFG_DIR) ~/nagios3.$(shell date '+%s')
	${GIT} clone $(GIT_REPO_URL) $(CFG_DIR)
	cd $(CFG_DIR) ; ${GIT} submodule update --init --recursive

map:
	${LN} -vsf ../../../..${CFG_DIR}/map/statusmap.php ${HTDOCS_DIR}/map.php

logos:
	${MKDIR} -vp ${HTDOCS_DIR}/images/logos
	${LN} -vsf ../../../../../../${CFG_DIR}/logos/local ${HTDOCS_DIR}/images/logos/local

deps-apt:
	${APTITUDE} --assume-yes install nagios3 nagios-plugins+M nagios-plugins-basic+M nagios-plugins-contrib monitoring-plugins+M monitoring-plugins-basic+M monitoring-plugins-standard+M
	${APTITUDE} --assume-yes install libgd-tools

apache-cfg:
	${A2ENMOD} mpm_prefork auth_basic auth_digest
	${A2ENCONF} $(HTTPD_CONF)
	${SERVICE} apache2 restart
