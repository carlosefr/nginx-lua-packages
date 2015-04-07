This repository contains quick and dirty scripts to build OpenResty
(http://openresty.org/) Linux packages, mostly for testing purposes.

Right now only Debian packages are built, by running:

    make deb

The OpenResty bundle will be downloaded and built, and the resulting
".deb" package will end up inside the "build" directory.
