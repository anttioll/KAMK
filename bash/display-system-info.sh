#!/usr/bin/env bash
# Learning AWK and sed
# Antti Ollikainen, 2/2023

if [[ -e /usr/lib/os-release ]]; then
	OS=`awk '/PRETTY_NAME/ {print $0}' /usr/lib/os-release | sed -e "s/PRETTY_NAME=//g;s/\"*//g"`
else
	OS="Some `uname`"
fi

KERNEL_VER=`uname -r`
UPTIME=`uptime -p`
DATE=`date`

DISKS=`df -hx tmpfs -x devtmpfs`
CPU_USAGE=`ps axo pcpu,user,pid,start,comm --sort=-pcpu | head -n 6`
FREE_MEM=`awk '/MemFree/ {print $2/1024}' /proc/meminfo`
TOTAL_MEM=`awk '/MemTotal/ {print $2/1024}' /proc/meminfo`
CPU=`awk '/model name/ {for (i=1; i<=3; i++) {$i=""}; print $0; exit}' /proc/cpuinfo`

if [[ `lspci` ]]; then
	GPU=`lspci | awk '/VGA compatible controller/ {for (i=1; i<=4; i++) {$i=""}; print $0; exit}'`
else
	GPU="Couldn't determine the graphics card"
fi

if [[ -z $HOSTNAME ]]; then
	HOSTNAME=`hostname`
fi

NIC=`route -n | awk '$1=="0.0.0.0" {print $8; exit}'`

if [[ `nmcli device show $NIC` ]]; then
	IPv4=`nmcli device show $NIC | awk '/IP4.ADDRESS/ {print $2}'`
	IPv6=`nmcli device show $NIC | awk '/IP6.ADDRESS/ {print $2}'`
else
	IPv4="Couldn't determine IPv4 address for $NIC. Try the command \"ip a\" or \"ifconfig\""
	IPv6="Couldn't determine IPv6 address for $NIC. Try the command \"ip a\" or \"ifconfig\""
fi

DEFAULT_GW=`route -n | awk '/0.0.0.0/ {print $2; exit}'`

echo
echo "Operating system: $OS"
echo "Kernel version: $KERNEL_VER"
echo "Uptime: $UPTIME"
echo "System date: $DATE"
echo
echo "Disks:"
echo "$DISKS"
echo
echo "Free memory: $FREE_MEM MB / $TOTAL_MEM MB"
echo
echo "CPU: $CPU"
echo "GPU: $GPU"
echo
echo "Five most CPU-intensive processes:"
echo "$CPU_USAGE"
echo
echo "Hostname: $HOSTNAME"
echo "Network interface card: $NIC"
echo "IPv4 address for $NIC: $IPv4"
echo "IPv6 address for $NIC: $IPv6"
echo "Default gateway: $DEFAULT_GW"
echo

exit
