This repository contains some quick and dirty scripts for testing Lua
support in nginx, both Docker containers and packaging for OpenResty
(http://openresty.org/).

For custom nginx+lua containers plus a couple of modules that I find
essential, run:

    make docker

Then you can try it out by starting an example configuration with:

    sudo docker run --name nginx-lua-hello -d -p 8080:80 nginx-lua-hello

Point your browser to http://localhost:8080/lua and you've reached your
destination.

For OpenResty, right now only Debian packages are built by running:

    make deb

The OpenResty bundle will be downloaded and built, and the resulting
".deb" package will end up inside the "build" directory.
