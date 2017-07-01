#!/usr/bin/env bash

#COLORS
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

## Update package manager cache
echo -e "$Yellow \n Installing Apache2 $Color_Off"
sudo apt-get update

## Install Composer Dependencies
echo -e "$Cyan \n Installing Composer Dependencies $Color_Off"
sudo apt-get install curl php-cli php-mbstring git unzip -y

cd ~
## Get Composer installer
echo -e "$Cyan \n Getting Composer installer $Color_Off"
curl -sS https://getcomposer.org/installer -o composer-setup.php

## Verify Composer installer
echo -e "$Purple \n Verifying Composer installer $Color_Off"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"

## Set Composer globally
echo -e "$Cyan \n Setting Composer globally $Color_Off"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
echo -e "$Green \n Composer was installed globally, run composer command to display all commands supported $Color_Off"

## Install php-cs-fixer
echo -e "$Cyan \n Installing php-cs-fixer globally $Color_Off"
composer global require friendsof/php-cs-fixer
echo -e "$Cyan \n Exporting $PATH $Color_Off"
export PATH="$PATH:$HOME/.composer/vendor/bin"

## Move laravel fixet to /home
echo -e "$Cyan \n Creating Laravel fixer $Color_Off"
mv laravel-fixer.dist ~/.php_cs.dist

## Add alias to create pre-co
echo -e "$Cyan \n Creating alias to use pre-commit feature $Color_Off"
echo "alias pre-commit-init='cp ~/php-cs-fixer-pre-commit/pre-commit $(pwd)/.git/hooks/ && sudo chmod +x $(pwd)/.git/hooks/pre-commit" >>

echo -e "$Green \n Setting up complete, in order to use the pre-commit feature go to root project and run pre-commit-init $Color_Off"