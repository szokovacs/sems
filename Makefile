.DEFAULT_GOAL:=all

.PHONY: all
all: modules

COREPATH=core
include Makefile.defs

NAME=$(APP_NAME)

subdirs = core apps tools

.PHONY: clean
clean:
	-@rm -f *.so
	-@for r in $(subdirs) doc "" ; do \
		if [ -n "$$r" ]; then \
			echo "" ; \
			echo "making $$r" ; \
			$(MAKE) -C $$r clean ; \
		fi ; \
	done

.PHONY: modules
modules:
	-@for r in $(subdirs) "" ; do \
		if [ -n "$$r" ]; then \
			echo  "" ; \
			echo  "making $$r" ; \
			$(MAKE) -C $$r all; \
		fi ; \
	done 

.PHONY: install
install:
	-@for r in $(subdirs) "" ; do \
		if [ -n "$$r" ]; then \
			echo "" ; \
			echo "" ; \
			$(MAKE) -C $$r install; \
		fi ; \
	done
	@echo ""
	@echo "*** install complete. Run SEMS with "
	@echo "*** "
	@echo "***   $(bin-target)$(NAME) -f $(cfg-target)sems.conf"


.PHONY: dist
dist: tar

.PHONY: tar
tar: 
	$(TAR) -C .. \
		--exclude=$(notdir $(CURDIR))/tmp \
		--exclude=core/$(notdir $(CURDIR))/tmp \
		--exclude=.svn* \
		--exclude=.git* \
		--exclude=.\#* \
		--exclude=*.[do] \
		--exclude=*.la \
		--exclude=*.lo \
		--exclude=*.so \
		--exclude=*.il \
		--exclude=*.gz \
		--exclude=*.bz2 \
		--exclude=*.tar \
		--exclude=*~ \
		-cf - $(notdir $(CURDIR)) | \
			(mkdir -p tmp/_tar1; mkdir -p tmp/_tar2 ; \
			    cd tmp/_tar1; $(TAR) -xf - ) && \
			    mv tmp/_tar1/$(notdir $(CURDIR)) \
			       tmp/_tar2/"$(NAME)-$(RELEASE)" && \
			    (cd tmp/_tar2 && $(TAR) \
			                    -zcf ../../"$(NAME)-$(RELEASE)".tar.gz \
			                               "$(NAME)-$(RELEASE)" ) ; \
			    rm -rf tmp

.PHONY: rpm
rpm: 
	RPM_VERSION=`cat pkg/rpm/sems.spec|grep -e "^Version:"|awk '{print $$2}'`; \
	echo "RPM_VERSION=$${RPM_VERSION}"; \
	        $(TAR) -C .. \
                --exclude=$(notdir $(CURDIR))/tmp \
                --exclude=core/$(notdir $(CURDIR))/tmp \
                --exclude=.svn* \
                --exclude=.git* \
                --exclude=.\#* \
                --exclude=*.[do] \
                --exclude=*.la \
                --exclude=*.lo \
                --exclude=*.so \
                --exclude=*.il \
                --exclude=*.gz \
                --exclude=*.bz2 \
                --exclude=*.tar \
                --exclude=*~ \
                -cf - $(notdir $(CURDIR)) | \
                        (mkdir -p tmp/_tar1; mkdir -p tmp/_tar2 ; \
                            cd tmp/_tar1; $(TAR) -xf - ) && \
                            mv tmp/_tar1/$(notdir $(CURDIR)) \
                               tmp/_tar2/"$(NAME)-$${RPM_VERSION}" && \
                            (cd tmp/_tar2 && $(TAR) \
                                            -zcf ../../"$(NAME)-$${RPM_VERSION}".tar.gz \
                                                       "$(NAME)-$${RPM_VERSION}" ) ; \
                            rm -rf tmp; \
		mkdir p ~/rpmbuild/SOURCES; \
		cp "$(NAME)-$${RPM_VERSION}".tar.gz ~/rpmbuild/SOURCES
		rpmbuild -ba pkg/rpm/sems.spec
  
.PHONY: doc
doc:
	make -C doc/ doc

.PHONY: fulldoc
fulldoc:
	make -C doc/ fulldoc
