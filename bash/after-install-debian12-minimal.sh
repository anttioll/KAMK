#!/usr/bin/bash
# Debian 12 Bookworm minimaalisen asennuksen jälkeinen skripti
# 10/2023 Antti Ollikainen

sed -i "1d,2d" /etc/apt/sources.list

apt update -q -y && apt upgrade -q -y

apt install -q -y man vim lsof

echo "alias ll='ls -lah --color=auto'" > /etc/profile.d/alias.sh
echo "alias rm='rm -i'" >> /etc/profile.d/alias.sh
echo "alias mv='mv -i'" >> /etc/profile.d/alias.sh
echo "alias cp='cp -i'" >> /etc/profile.d/alias.sh

echo "set nu!" >> /etc/vim/vimrc
echo "colorscheme desert" >> /etc/vim/vimrc
echo "set expandtab" >> /etc/vim/vimrc
echo "set tabstop=2" >> /etc/vim/vimrc
echo "set shiftwidth=2" >> /etc/vim/vimrc
echo "set autoindent" >> /etc/vim/vimrc

sed -i "s/#\?LoginGraceTime.*/LoginGraceTime 1m/g" /etc/ssh/sshd_config
sed -i "s/#\?PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
sed -i "s/#\?MaxAuthTries.*/MaxAuthTries 3/g" /etc/ssh/sshd_config
sed -i "s/#\?PermitEmptyPasswords.*/PermitEmptyPasswords no/g" /etc/ssh/sshd_config
sed -i "s/#\?AllowTcpForwarding.*/AllowTcpForwarding no/g" /etc/ssh/sshd/config
sed -i "s/#\?X11Forwarding.*/X11Forwarding no/g" /etc/ssh/sshd_config
sed -i "s/#\?PermitTunnel.*/PermitTunnel no/g" /etc/ssh/sshd_config