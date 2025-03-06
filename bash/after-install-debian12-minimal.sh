#!/usr/bin/bash
# Debian 12 Bookworm minimaalisen asennuksen jälkeinen skripti
# 10/2023 Antti Ollikainen

#sed -i "1d,2d" /etc/apt/sources.list

apt update -q -y && apt upgrade -q -y
apt install -q -y man vim lsof dnsutils iptables-persistent chrony

ALIAS_SH=/etc/profile.d/alias.sh
echo "alias ll='ls -lah --color=auto'" > $ALIAS_SH
echo "alias rm='rm -i'" >> $ALIAS_SH
echo "alias mv='mv -i'" >> $ALIAS_SH
echo "alias cp='cp -i'" >> $ALIAS_SH

VIM_CONF=/etc/vim/vimrc
echo "set nu!" >> $VIM_CONF
echo "colorscheme desert" >> $VIM_CONF
echo "set expandtab" >> $VIM_CONF
echo "set tabstop=2" >> $VIM_CONF
echo "set shiftwidth=2" >> $VIM_CONF
echo "set autoindent" >> $VIM_CONF

CHRONY_CONF=/etc/chrony/chrony.conf
echo "server 10.10.10.5" > $CHRONY_CONF
echo "server 10.10.10.6" >> $CHRONY_CONF
echo "driftfile /var/lib/chrony/chrony.drift" >> $CHRONY_CONF
echo "#log tracking measurements statistics" >> $CHRONY_CONF
echo "logdir /var/log/chrony" >> $CHRONY_CONF
echo "maxupdateskew 100.0" >> $CHRONY_CONF
echo "rtcsync" >> $CHRONY_CONF
echo "makestep 1 3" >> $CHRONY_CONF
echo "leapsectz right/UTC" >> $CHRONY_CONF
echo "cmdport 0" >> $CHRONY_CONF

SSHD_CONF=/etc/ssh/sshd_config
sed -i "s/#\?LoginGraceTime.*/LoginGraceTime 1m/g" $SSHD_CONF
sed -i "s/#\?PermitRootLogin.*/PermitRootLogin no/g" $SSHD_CONF
sed -i "s/#\?MaxAuthTries.*/MaxAuthTries 3/g" $SSHD_CONF
sed -i "s/#\?PermitEmptyPasswords.*/PermitEmptyPasswords no/g" $SSHD_CONF
sed -i "s/#\?AllowTcpForwarding.*/AllowTcpForwarding no/g" $SSHD_CONF
sed -i "s/#\?X11Forwarding.*/X11Forwarding no/g" $SSHD_CONF
sed -i "s/#\?PermitTunnel.*/PermitTunnel no/g" $SSHD_CONF
