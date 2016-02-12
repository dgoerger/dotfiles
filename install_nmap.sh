#!/bin/bash

# fetch source
cd /tmp
curl -LO https://nmap.org/dist/nmap-7.01.tgz
tar -xf nmap-7.01.tgz
cd /tmp/nmap-7.01

# install build deps
sudo dnf install -y gcc-c++ openssl-devel redhat-rpm-config

# set sane compile options
export CFLAGS='-O2 -g -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -m64 -mtune=generic'
export CXXFLAGS='-O2 -g -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -m64 -mtune=generic'
export FFLAGS='-O2 -g -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -m64 -mtune=generic -I/usr/lib64/gfortran/modules'
export FCFLAGS='-O2 -g -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -m64 -mtune=generic -I/usr/lib64/gfortran/modules'
export LDFLAGS='-Wl,-z,relro -specs=/usr/lib/rpm/redhat/redhat-hardened-ld'

# compile!
./configure --without-zenmap
make
sudo make install
