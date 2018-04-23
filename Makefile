HUGO?=hugo
HUGOOPTS=

BASEDIR=$(CURDIR)
INPUTDIR=$(BASEDIR)/content
OUTPUTDIR=$(BASEDIR)/public
CONFFILE=$(BASEDIR)/config.yaml

SSH_HOST=janw.xyz
SSH_PORT=22
SSH_USER=willhaus
SSH_TARGET_DIR=/var/www/virtual/willhaus/janw.xyz

DEBUG ?= 0
ifeq ($(DEBUG), 1)
	HUGOOPTS += --debug
endif

help:
	@echo 'Makefile for a hugo Web site                                           '
	@echo '                                                                          '
	@echo 'Usage:                                                                    '
	@echo '   make html                           (re)generate the web site          '
	@echo '   make clean                          remove the generated files         '
	@echo '   make publish                        generate using production settings '
	@echo '   make serve [PORT=8000]              serve site at http://localhost:8000'
	@echo '   make serve-global [SERVER=0.0.0.0]  serve (as root) to $(SERVER):80    '
	@echo '   make ssh_upload                     upload the web site via SSH        '
	@echo '   make rsync_upload                   upload the web site via rsync+ssh  '
	@echo '                                                                          '
	@echo 'Set the DEBUG variable to 1 to enable debugging, e.g. make DEBUG=1 html   '
	@echo '                                                                          '

html:
	$(HUGO) -c $(INPUTDIR) -d $(OUTPUTDIR)

clean:
	[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)

serve:
ifdef PORT
	$(HUGO) serve -p $(PORT)
else
	$(HUGO) serve
endif

serve-global:
ifdef SERVER
	$(HUGO) serve --bind $(SERVER) --port 80
else
	$(HUGO) serve --bind 0.0.0.0 --port 80
endif

ssh_upload:
	scp -P $(SSH_PORT) -r $(OUTPUTDIR)/* $(SSH_USER)@$(SSH_HOST):$(SSH_TARGET_DIR)

rsync_upload:
	rsync -e "ssh -p $(SSH_PORT)" -P -rvzc --cvs-exclude --delete $(OUTPUTDIR)/ $(SSH_USER)@$(SSH_HOST):$(SSH_TARGET_DIR)

publish: clean html rsync_upload

.PHONY: html help clean serve serve-global publish upload ssh_upload rsync_upload