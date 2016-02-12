#!/bin/bash

# compile links from source: http://links.twibright.com/download.php
# fetch source
cd /tmp
curl -LO http://links.twibright.com/download/links-2.12.tar.gz
tar -xf links-2.12.tar.gz
cd /tmp/links-2.12

# install build deps
sudo dnf install -y gcc libevent-devel openssl-devel redhat-rpm-config

# set sane compile options
export CFLAGS='-O2 -g -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -m64 -mtune=generic'
export CXXFLAGS='-O2 -g -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -m64 -mtune=generic'
export FFLAGS='-O2 -g -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -m64 -mtune=generic -I/usr/lib64/gfortran/modules'
export FCFLAGS='-O2 -g -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -m64 -mtune=generic -I/usr/lib64/gfortran/modules'
export LDFLAGS='-Wl,-z,relro -specs=/usr/lib/rpm/redhat/redhat-hardened-ld'

# compile!
./configure -with-ssl
make
sudo make install
