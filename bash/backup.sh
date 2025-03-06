#!/usr/bin/env bash
# Skripti tekee varmuuskopion kansiosta TARGET_DIR kansioon SAVE_DIR
# Skripti on turhan monimutkainen ihan vain harjoituksen vuoksi
# Antti Ollikainen, TTK22SD, 1/2023

E_BADARGS=64
TARGET_DIR=/home/ao/koulu/bash/temp
SAVE_DIR=/home/ao/data
START_DIR=`pwd`
BACKUP_FILE=backup_`date +%F_%H%M`.tar.gz

if [[ $# -gt 0 ]]; then
	case $1 in
		-h | --help)
			echo "Tekee tar.gz -varmuuskopion kansiosta $TARGET_DIR kansioon $SAVE_DIR"
			exit $E_BADARGS;;
		*)
			echo "Käyttö: `basename $0` [optional -h tai --help]"
			exit $E_BADARGS;;
	esac
fi

if [[ ! `grep -qs $SAVE_DIR /proc/mounts` ]]; then
	echo "Anna root-oikeudet /dev/sdb1 mounttaamista varten"
	sudo mount /dev/sdb1 $SAVE_DIR
	echo "Mountattu /dev/sdb1 kansioon $SAVE_DIR"
fi

cd $SAVE_DIR
files=`ls`

for file in $files; do
	if [[ $file = $BACKUP_FILE ]]; then
		mv $BACKUP_FILE old_$BACKUP_FILE
		break
	fi
done

cd $TARGET_DIR
tar -czf $SAVE_DIR/$BACKUP_FILE ./*
echo "Luotu varmuuskopio onnistuneesti kansiosta $TARGET_DIR nimellä $BACKUP_FILE kansioon $SAVE_DIR"

cd $START_DIR
exit
