#!/bin/bash

# fetch source
cd /tmp
curl -LO https://github.com/tmux/tmux/releases/download/2.1/tmux-2.1.tar.gz
tar -xf tmux-2.1.tar.gz
cd /tmp/tmux-2.1

# install build deps
sudo dnf install -y gcc libevent-devel ncurses-devel redhat-rpm-config

# set sane compile options
export CFLAGS='-O2 -g -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -m64 -mtune=generic'
export CXXFLAGS='-O2 -g -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -m64 -mtune=generic'
export FFLAGS='-O2 -g -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -m64 -mtune=generic -I/usr/lib64/gfortran/modules'
export FCFLAGS='-O2 -g -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -m64 -mtune=generic -I/usr/lib64/gfortran/modules'
export LDFLAGS='-Wl,-z,relro -specs=/usr/lib/rpm/redhat/redhat-hardened-ld'

# compile!
./configure
make
sudo make install

# copy in bash completion script
sudo cp /tmp/tmux-2.1/examples/bash_completion_tmux.sh /etc/bash_completion.d/tmux
