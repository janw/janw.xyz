HUGO?=hugo
HUGOOPTS=

BASEDIR=$(CURDIR)
INPUTDIR=$(BASEDIR)/content
OUTPUTDIR=$(BASEDIR)/public
CONFFILE=$(BASEDIR)/config.yaml

SSH_HOST=box.janw.xyz
SSH_PORT=22
SSH_USER=jan
SSH_TARGET_DIR=/var/www/janw.xyz

DEBUG ?= 0
ifeq ($(DEBUG), 1)
	HUGOOPTS += --debug
endif

help:
	@echo 'Makefile for a hugo Web site                                              '
	@echo '                                                                          '
	@echo 'Usage:                                                                    '
	@echo '   make html                           (re)generate the web site          '
	@echo '   make clean                          remove the generated files         '
	@echo '   make publish                        generate using production settings '
	@echo '   make serve [PORT=8000]              serve site at http://localhost:8000'
	@echo '   make upload                         upload the web site via rsync+ssh  '
	@echo '                                                                          '
	@echo 'Set the DEBUG variable to 1 to enable debugging, e.g. make DEBUG=1 html   '
	@echo '                                                                          '

html:
	$(HUGO) $(HUGOOPTS) -c $(INPUTDIR) -d $(OUTPUTDIR)

clean:
	[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)

serve:
ifdef PORT
	$(HUGO) $(HUGOOPTS) serve -p $(PORT)
else
	$(HUGO) $(HUGOOPTS) serve
endif

publish: clean html
	rsync -e "ssh -p $(SSH_PORT)" -P -rvzc --delete --cvs-exclude $(OUTPUTDIR)/ $(SSH_USER)@$(SSH_HOST):$(SSH_TARGET_DIR)

icons:
	bash fa_icons_download.sh

update_assets: icons
	npm update

init: icons
	npm install

build: clean init html

.PHONY: html help clean serve publish icons update_assets init build
