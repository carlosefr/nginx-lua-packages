#
# Makefile (for GNU Make)
#


PREFIX ?= /opt/openresty
OS := $(shell uname -s)
NPROCS = 1
OPENRESTY_VERSION = 1.7.10.1
PATH := $(PATH):/sbin


# Parallelize the build on Linux...
ifeq ($(OS),Linux)
	NPROCS := $(shell grep -c ^processor /proc/cpuinfo)
endif
ifeq ($(OS),Darwin)
	NPROCS := $(shell sysctl -a | grep "hw.ncpu " | cut -d" " -f3)
endif
ifeq ($(OS),FreeBSD)
	NPROCS := $(shell sysctl -a | grep "hw.ncpu " | cut -d" " -f3)
endif


all:


clean:
	rm -rf build
	rm -rf upstream


upstream/ngx_openresty-$(OPENRESTY_VERSION).tar.gz:
	mkdir -p upstream
	cd upstream && wget http://openresty.org/download/ngx_openresty-$(OPENRESTY_VERSION).tar.gz


deb: upstream/ngx_openresty-$(OPENRESTY_VERSION).tar.gz
	rm -rf build
	test -x /usr/bin/dpkg-deb && test -x /usr/bin/fakeroot

        # Check for build dependencies...
	dpkg -l libreadline-dev | grep -q ^ii
	dpkg -l libncurses5-dev | grep -q ^ii
	dpkg -l libpcre3-dev | grep -q ^ii
	dpkg -l libssl-dev | grep -q ^ii
	dpkg -l perl | grep -q ^ii
	
	mkdir -p build
	tar -C build -zxf upstream/ngx_openresty-$(OPENRESTY_VERSION).tar.gz
	
	$(eval PACKAGE_VERSION := $(OPENRESTY_VERSION)-$(shell date +%Y%m%d)~$(shell lsb_release -c | awk '{print $$2}' | tr '[A-Z]' '[a-z]'))
	$(eval PACKAGE_ARCH := $(shell dpkg-architecture -qDEB_BUILD_ARCH))
	$(eval PACKAGE_NAME := openresty-$(PACKAGE_VERSION))

	cd build/ngx_openresty-$(OPENRESTY_VERSION) && ./configure --with-pcre-jit --with-ipv6 --prefix=$(PREFIX)
	cd build/ngx_openresty-$(OPENRESTY_VERSION) && $(MAKE) -j$(NPROCS)
	cd build/ngx_openresty-$(OPENRESTY_VERSION) && $(MAKE) install DESTDIR="$(PWD)/build/$(PACKAGE_NAME)"

	sed -i 's|#user *nobody;|user resty;|g' "build/$(PACKAGE_NAME)$(PREFIX)/nginx/conf/nginx.conf"

	mkdir -p "build/$(PACKAGE_NAME)/etc/init.d"
	cp debian/openresty-init.sh "build/$(PACKAGE_NAME)/etc/init.d/openresty"
	sed -i 's|__OPENRESTY_ROOT__|$(PREFIX)|g' "build/$(PACKAGE_NAME)/etc/init.d/openresty"
	chmod 755 "build/$(PACKAGE_NAME)/etc/init.d/openresty"

	mkdir -p "build/$(PACKAGE_NAME)/DEBIAN"
	cd debian && cp compat conffiles control postinst postrm prerm "../build/$(PACKAGE_NAME)/DEBIAN"
	sed -i 's|__OPENRESTY_ROOT__|$(PREFIX)|g' "build/$(PACKAGE_NAME)/DEBIAN"/*
	printf "Version: $(PACKAGE_VERSION)\nArchitecture: $(PACKAGE_ARCH)\n" >> "build/$(PACKAGE_NAME)/DEBIAN/control"

	find "build/$(PACKAGE_NAME)$(PREFIX)" -perm /ugo+x -type f ! -name '*.sh' | xargs dpkg-shlibdeps -xopenresty --ignore-missing-info -Tbuild/dependencies
	sed -i 's/^shlibs:Depends=//' build/dependencies
	sed -i "s/\(Depends:.*\)$$/\1, $$(cat build/dependencies)/" "build/$(PACKAGE_NAME)/DEBIAN/control"

	chmod -R u+w,go-w "build/$(PACKAGE_NAME)"
	fakeroot dpkg-deb --build "build/$(PACKAGE_NAME)"


docker:
	sudo docker build -t nginx-lua docker
	sudo docker build -t nginx-lua-hello docker/hello


.PHONY: all clean deb docker


# EOF - Makefile
