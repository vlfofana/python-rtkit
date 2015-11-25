BUILD_IN=tmp
PACKAGES_IN=builds
DEBIAN_TEMPLATE=pkg/deb
DATA_SOURCE=data
DATA_TARGET=tmp/argus

PYTHON=`which python`
CWD=$(CURDIR)

BUILD_DIR=$(CWD)/$(BUILD_IN)
PACKAGES_DIR=$(CWD)/$(PACKAGES_IN)
DEBIAN_TEMPLATE_DIR=$(CWD)/$(DEBIAN_TEMPLATE)
DATA_SOURCE_DIR=$(CWD)/$(DATA_SOURCE)

PACKAGE:=$(shell cat $(CWD)/setup.py | grep 'name=' | sed "s/.*name='//" | sed "s/',//")
VERSION:=$(shell cat $(CWD)/setup.py | grep 'version=' | sed "s/.*version='//" | sed "s/',//")


all:
	make source deb clean

source:
	mkdir -p $(BUILD_DIR)

	$(PYTHON) setup.py sdist --dist-dir=$(BUILD_DIR)

	cd $(BUILD_DIR); tar xzf $(PACKAGE)-$(VERSION).tar.gz

deb:
	cp -r $(DEBIAN_TEMPLATE_DIR) $(BUILD_DIR)/$(PACKAGE)-$(VERSION)/debian

	cat $(DEBIAN_TEMPLATE_DIR)/changelog | sed "s/#PACKAGE#/$(PACKAGE)/" | sed "s/#VERSION#/$(VERSION)/" \
	    > $(BUILD_DIR)/$(PACKAGE)-$(VERSION)/debian/changelog

	cat $(DEBIAN_TEMPLATE_DIR)/control | sed "s/#PACKAGE#/$(PACKAGE)/" | sed "s/#VERSION#/$(VERSION)/" \
	    > $(BUILD_DIR)/$(PACKAGE)-$(VERSION)/debian/control

	cd $(BUILD_DIR)/${PACKAGE}-${VERSION}; dpkg-buildpackage -rfakeroot -uc -us -b

	mkdir -p $(PACKAGES_DIR)

	mv $(BUILD_DIR)/python-${PACKAGE}_${VERSION}_all.deb $(PACKAGES_DIR)/

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(CWD)/argus.egg-info
