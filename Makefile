VERSION := $(shell python setup.py --version)

all: build

sources: clean
	$(eval TMPDIR := $(shell mktemp -d))
	# Populate the spec file with correct version from setup.py
	tar czf "$(TMPDIR)/sgmanager.tar.gz" ../sgmanager
	mv "$(TMPDIR)/sgmanager.tar.gz" sgmanager.tar.gz
	rmdir "$(TMPDIR)"

build install test:
	python setup.py $@

rpm: sources
	# Prepare directories and source for rpmbuild
	mkdir -p build/rpm/SOURCES
	cp sgmanager*.tar.gz build/rpm/SOURCES/
	mkdir -p build/rpm/SPECS
	cp sgmanager.spec build/rpm/SPECS/
	# Build RPM
	rpmbuild --define "_topdir $(CURDIR)/build/rpm" -ba build/rpm/SPECS/sgmanager.spec

clean:
	rm -f sgmanager.tar.gz
	rm -rf sgmanager.egg-info
	rm -rf build
	rm -rf dist

version:
	# Use for easier version bumping.
	# Helps keeping version consistent both in setup.py and sgmanager.spec
	@echo "Current version: $(VERSION)"
	@read -p "Type new version: " newversion; \
	sed -i -e "s/    'version': .*/    'version': '$$newversion',/" setup.py; \
	sed -i -e "s,Version:	.*,Version:	$$newversion," sgmanager.spec

tag:
	git tag "v$(VERSION)"
