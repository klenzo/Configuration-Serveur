#!/bin/bash

clear

echo '############################################################################'
echo '##########                                                        ##########'
echo '##########   Bonjour et bienvenue sur mon script INSTALL SERVER   ##########'
echo '##########                                                        ##########'
echo '############################################################################'
echo ''

echo '########################## MISE A JOUR DU SYSTEME ##########################'
sudo apt-get update && sudo apt-get upgrade -y
clear
echo '############################## INSTALL PAQUETS #############################'


# Vérification de la commande WP
command -v vim > /dev/null

# Si la commande WP n'existe pas, demander d'insaller
if [[ $? != 0 ]]; then
    read -p "Souhaitez-vous installer vim ? (Y/N) [Y] " repInstall

    # Vérification de la réponse
    if [[ $repInstall == 'Y' || $repInstall == 'y' || $repInstall == '' ]]; then
        echo "Installation de ' VIM ' en cours ..."
        sudo apt-get install vim -y > /dev/null
    fi

else
    echo "VIM est déjà installer"
fi

# Vérification de la commande WP
command -v apache2 > /dev/null

# Si la commande WP n'existe pas, demander d'insaller
if [[ $? != 0 ]]; then
    read -p "Souhaitez-vous installer apache2 ? (Y/N) [Y] " repInstall

    # Vérification de la réponse
    if [[ $repInstall == 'Y' || $repInstall == 'y' || $repInstall == '' ]]; then
        echo "Installation de ' apache2 ' en cours ..."
        sudo apt-get install apache2 -y > /dev/null
    fi
else
    echo "apache2 est déjà installer"
fi

# Vérification de la commande WP


command -v php5-cli > /dev/null
error=$?
command -v php > /dev/null

# Si la commande WP n'existe pas, demander d'insaller

if [[ $? != 0 || $error != 0 ]]; then
    read -p "Souhaitez-vous installer php ? (Y/N) [Y] " repInstall
    
    sudo apt-get install php5-cli -y > /dev/null

    # Vérification de la réponse
    if [[ $repInstall == 'Y' || $repInstall == 'y' || $repInstall == '' ]]; then
        installPHP='on'
        read -p "Souhaitez-vous installer ' php5 ' ou ' php5-fpm ' ? [php5] " phpType

        # Installation de PHP5
        if [[ $phpType == 'php5' || $phpType == 'PHP5' || $phpType == '' ]]; then
            echo "Installation de ' php5 ' en cours ..."
            sudo apt-get install php5 -y
        else

        # Installaion de PHP5-FPM
            echo "Installation de ' php5-fpm ' en cours ..."
            sudo apt-get install -y php5-fpm libapache2-mod-fastcgi > /dev/null
            sudo service php5-fpm restart > /dev/null

            echo "<IfModule mod_fastcgi.c>
                  AddHandler php5-fcgi .php
                  Action php5-fcgi /php5-fcgi
                  Alias /php5-fcgi /usr/lib/cgi-bin/php5-fcgi
                  FastCgiExternalServer /usr/lib/cgi-bin/php5-fcgi -socket /var/run/php5-fpm.sock -pass-header  Authorization

                  <Directory /usr/lib/cgi-bin>
                      Require all granted
                  </Directory>
                </IfModule>" | sudo tee /etc/apache2/mods-available/fastcgi.conf > /dev/null

            
            echo "ServerName localhost" | sudo tee --append /etc/apache2/apache2.conf > /dev/null

            sudo a2enmod actions > /dev/null
            sudo service apache2 restart > /dev/null
        fi # FIN de PHP5

        # PHP5-CURL
        read -p "Souhaitez-vous installer ' php-curl ' ? [Y] " installCurl
        if [[ $installCurl == 'Y' || $installCurl == 'y' || $installCurl == '' ]]; then
            echo "Installation de ' php5-curl ' en cours ..."
            sudo apt-get install php5-curl -y > /dev/null
        fi

        # PHP5-GD
        read -p "Souhaitez-vous installer ' php-gd ' ? [Y] " installGD
        if [[ $installGD == 'Y' || $installGD == 'y' || $installGD == '' ]]; then
            echo "Installation de ' php5-gd ' en cours ..."
            sudo apt-get install php5-gd -y > /dev/null
        fi
    else
        installPHP='off'
    fi
else
    echo "php est déjà installer"
fi

# Vérification de la commande WP
command -v mysql > /dev/null

# Si la commande WP n'existe pas, demander d'insaller
if [[ $? != 0 ]]; then
    read -p "Souhaitez-vous installer ' mysql-server ' ? (Y/N) [Y] " repInstall

    # Vérification de la réponse
    if [[ $repInstall == 'Y' || $repInstall == 'y' || $repInstall == '' ]]; then
        # Installation de DBCONFIG
        echo "Installation de ' debconf-utils ' en cours ..."
        sudo apt-get install debconf-utils -y > /dev/null

        read -p "Entrer le mot de passe root : " rootPass

        echo mysql-server mysql-server/root_password password $rootPass > /dev/null | sudo debconf-set-selections > /dev/null
        echo mysql-server mysql-server/root_password_again password $rootPass > /dev/null | sudo debconf-set-selections > /dev/null

        echo "Installation de ' mysql-server ' en cours ..."
        sudo apt-get install mysql-server -y > /dev/null
        
        if [[ $installPHP == 'on' ]]; then
            sudo apt-get install php5-mysql -y > /dev/null
        fi

        echo "[client]
user=root
password=${rootPass}" > "$HOME/my.cnf"

        read -p "Souhaitez-vous créer une base de donnés ? (Y/N) [Y] " creatDB
        if [[ $creatDB == 'Y' || $creatDB == 'y' || $creatDB == '' ]]; then
            read -p "Entrer le nom de la base : [mabdd] " nameDB
            if [[ $nameDB == '' ]]; then
                nameDB='mabdd'
            fi
            db="CREATE DATABASE ${nameDB};"
        else
            db=""
        fi

        read -p "Souhaitez-vous créer un utilisateur ? (Y/N) [Y] " creatUser
        if [[ $creatUser == 'Y' || $creatUser == 'y' || $creatUser == '' ]]; then
            read -p "Entrer le nom d'utilisateur ? [admin] " nameUser
            if [[ $nameUser == '' ]]; then
                nameUser="admin"
            fi
            read -p "Entrer un mot de passe pour ' ${nameUser} ' [0000] " passUser
            if [[ $passUser == '' ]]; then
                passUser="0000"
            fi
            read -p "Entrer le host pour ' ${nameUser} ' [localhost] " hostUser
            if [[ $hostUser == '' ]]; then
                hostUser="localhost"
            fi

            user="CREATE USER '${nameUser}'@'${hostUser}' IDENTIFIED BY '${passUser}';"
        else
            user=""
        fi
    fi

    if [[ $db != '' && $user != '' ]]; then
        read -p "Souhaitez-vous donner les droits de ${nameDB} à ${nameUser} ? (Y/N) [Y] " repFlush

        if [[ $repFlush == 'Y' || $repFlush == 'y' || $repFlush == '' ]]; then
            flush="GRANT ALL PRIVILEGES ON ${nameDB}.* TO '${nameUser}'@'${hostUser}'; FLUSH PRIVILEGES;"
        else
            flush=""
        fi
    
        requete="${db} ${user} ${flush} exit"

        mysql -uroot -e $requete > /dev/null

        read -p "Souhaitez-vous importer une base SQL ? (Y/N) [N] " repImport

        if [[ $repImport == 'Y' || $repImport == 'y' ]]; then
            read -p "Entrer le chemin du .sql " fileSQl
            if [[ -f $fileSQL ]]; then
                mysql "-u${nameUser}" $nameDB < $fileSQL > /dev/null
            else
                echo "Ce fichier n'existe pas ! On passe à autre chose .."
            fi
        fi
    fi

    sudo rm "$HOME/my.cnf" > /dev/null
else
    echo "mysql-server est déjà installer"
fi

read -p "Souhaitez-vous utiliser WP-CLI ? (Y/N) [N]" repWPCLI
if [[ $repWPCLI == 'y' || $repWPCLI == 'Y' ]]; then
    read -p "Entrer le chemin vers l'installer WP-CLI ? [./wp-cli_script.sh]" pathWPCLI
    if [[ $pathWPCLI == '' ]]; then
        pathWPCLI="./wp-cli_script.sh"
    fi
    bash $pathWPCLI
fi

# VHOST