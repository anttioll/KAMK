#!/usr/bin/env bash
# Harjoitusskripti ajettavaksi puhtaan asennuksen jälkeen
# Asettaa Bash-aliaksia, VIM-asetuksia ja luo käyttäjien home-kansioon bin-kansion omia skriptejä varten
# ja lisää kansion PATHiin.
# Antti Ollikainen, 1/2023

E_BADPERMS=77
ALIAS_FILE=/etc/profile.d/bash_aliases.sh

if [[ $UID != 0 ]]; then
	echo "Aja skripti root-oikeuksilla"
	exit $E_BADPERMS
fi

echo "alias ls=\"ls --color=auto\"" >> $ALIAS_FILE
echo "alias ll=\"ls -lah --color=auto\"" >> $ALIAS_FILE
echo "alias rm=\"rm -i\"" >> $ALIAS_FILE
echo "alias mv=\"mv -i\"" >> $ALIAS_FILE
echo "alias cp=\"cp -i\"" >> $ALIAS_FILE
chmod 644 $ALIAS_FILE

if [[ -e /etc/vimrc ]]; then
	VIMRC=/etc/vimrc
elif [[ -e /etc/vim/vimrc ]]; then
	VIMRC=/etc/vim/vimrc
else
	VIMRC=/dev/null
fi

echo "set nu!" >> $VIMRC
echo "set tabstop=2" >> $VIMRC
echo "colorscheme desert" >> $VIMRC

user_dirs=`ls /home`

for user in $user_dirs; do
	if [[ ! -d /home/$user/bin ]] && [[ $user != "lost+found" ]]; then
		mkdir /home/$user/bin
		chown $user:$user /home/$user/bin
		chmod 755 /home/$user/bin
		echo "PATH=${PATH}:/home/$user/bin" >> /home/$user/.bashrc
		# Kaikki joko käyttävät Vimiä tai itkevät ja käyttävät Vimiä
		echo "EDITOR=/usr/bin/vim" >> /home/$user/.bashrc
	fi
done

