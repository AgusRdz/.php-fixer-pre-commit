#!/usr/bin/env bash

#COLORS
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Cyan='\033[0;36m'         # Cyan


if [ ! hash composer 2>/dev/null ] || [ ! 'php-cs-fixer' --version >/dev/null 2>&1 ]; then
## Update package manager cache
echo -e "$Yellow \n Updating package manager cache $Color_Off"
apt-get update

## Install Composer Dependencies
echo -e "$Cyan \n Installing Composer Dependencies $Color_Off"
apt-get install curl php-cli php-mbstring git unzip -y
fi

cd ~
## Get Composer installer
echo -e "$Yellow \n Checking if Composer is already installed $Color_Off"
if ! hash composer 2>/dev/null; then
	echo -e "$Cyan \n Getting Composer installer $Color_Off"
	curl -sS https://getcomposer.org/installer -o composer-setup.php

	## Verify Composer installer
	echo -e "$Cyan \n Verifying Composer installer $Color_Off"
	php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"

	## Set Composer globally
	echo -e "$Cyan \n Setting Composer globally $Color_Off"
	sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
	php -r "unlink('composer-setup.php');"
	echo -e "$Green \n Composer was installed globally, run composer command to display all commands supported $Color_Off"
else
	echo -e "$Green \n Composer is already installed $Color_Off"
fi

## Install php-cs-fixer
echo -e "$Yellow \n Checking if php-cs-fixer is already installed $Color_Off"
if ! 'php-cs-fixer' --version >/dev/null 2>&1; then
	echo -e "$Cyan \n Installing php-cs-fixer globally $Color_Off"
	composer global require friendsofphp/php-cs-fixer --quiet
	if [ ! "$(grep -r 'export PATH="$HOME/.composer/vendor/bin:$PATH"' $HOME/.bashrc)" ]; then
		echo -e "$Cyan \n Exporting $PATH $Color_Off"
		echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc
	fi
else
	echo -e "$Green \n php-cs-fixer is already installed $Color_Off"
fi

currentuser=$(who | awk '{print $1}')
#sudo chown -R $currentuser:$currentuser $HOME/.composer
sudo chmod -R 0777 $HOME/.composer

## Move PSR1 and PSR2 rules to /home
echo -e "$Cyan \n Creating fixer rules $Color_Off"
cp ~/php-fixer-pre-commit/config-rules.dist ~/.php_cs.dist

echo -e "$Cyan \n Creating alias to use pre-commit feature $Color_Off"
if [ ! "$(grep '^alias pre-commit-init=' ~/.bashrc)" ]; then
	echo "alias pre-commit-init='cp $HOME/php-fixer-pre-commit/pre-commit \$(pwd)/.git/hooks/pre-commit && chmod +x \$(pwd)/.git/hooks/pre-commit'" >> ~/.bashrc
fi

#sudo chown -R $currentuser:$currentuser $HOME/.bashrc
sudo chmod -R 0777 $HOME/.bashrc
source $HOME/.bashrc

if [ -f ~/composer-setup.php ]; then
	rm ~/composer-setup.php
fi

echo -e "$Green \n Setting up complete, in order to use the pre-commit-init feature go to root project and run pre-commit-init $Color_Off"