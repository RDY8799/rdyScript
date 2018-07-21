#!/bin/bash

clear

$f="\033[0m";
$cvermelho="\033[1;31m";

if [ $(id -u) -eq 0 ]
then
clear
else
	if echo $(id) |grep sudo > /dev/null
	then
	clear
	echo "Você não é root"
	echo "Seu usuário esta no grupo sudo"
	echo -e "Para tornar-se root execute $cvermelho sudo su$f"
	exit
	else
	clear
	echo -e "Você não está como usuário root, nem com seus direitos (sudo)\nPara tornar-se root execute $cvermelho su$f e digite sua senha root"
	exit
	fi
fi

IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
if [[ "$IP" = "" ]]; then
IP=$(wget -qO- ipv4.icanhazip.com)
fi

echo "RDY SOFTWARE";
echo ""
echo "ESTE PAINEL NÃO É DE AUTORIA MINHA, APENAS O INSTALADOR"
echo ""
clear
echo "Atualizando..."
apt-get update && apt-get upgrade -y
apt-get install curl -y
clear
echo "Instalando apache..."
apt-get install apache2 -y
clear
echo "Instalando PHP5..."
apt-get install php5 libapache2-mod-php5 php5-mcrypt -y
clear
echo "Reiniciando apache..."
service apache2 restart
clear
echo "Instalando MySQL Server..."
apt-get install mysql-server
mysql_install_db
mysql_secure_installation
clear
echo "Instalando PHPMyAdmin..."
apt-get install phpmyadmin -y
php5enmod mcrypt
clear
echo "Reiniciando apache..."
service apache2 restart
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
apt-get install libssh2-1-dev libssh2-php -y
clear
echo "Criando Data Base ssh..."
mysql -h localhost -u root -p rootjunior -e "CREATE DATABASE ssh"
php -m |grep ssh2
apt-get install php5-curl
clear
echo "Reiniciando apache..."
service apache2 restart
clear
echo "Baixando arquivos..."
wget https://github.com/RDY8799/rdyScript/blob/master/PainelV5.rar
clear
echo "Extraindo arquivos..."
unrar x PainelV5.rar 
cd PainelV5
clear
echo "Movendo arquivos..."
for arqs in `ls`
do
rm /var/www/html/$arqs 2>/dev/null
mv $arqs /var/www/html
chmod +x /var/www/html/$arqs
done
read -p "Digite a senha que você definiu no PHPMYADMIN e MYSQL: " SENHA

mysql -h localhost -u root -p $SENHA -e "CREATE DATABASE ssh"

echo "<?php $pass = '$SENHA';?>" > var/www/html/pages/system/pass.php

clear

echo "Reiniciando apache..."
service apache2 restart

echo "Terminado!\nACESSE: $IP/admin/ \n\nUSUÁRIO E SENHA: admin"