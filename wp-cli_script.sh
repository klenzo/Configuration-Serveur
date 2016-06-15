#!/bin/bash

clear

echo '############################################################################'
echo '##############                                                ##############'
echo '##############   Bonjour et bienvenue sur mon script WP-CLI   ##############'
echo '##############                                                ##############'
echo '############################################################################'
echo ''

# Vérification de la commande WP
command -v wp > /dev/null

# Si la commande WP n'existe pas, demander d'insaller
if [[ $? != 0 ]]; then
    echo "Souhaitez-vous installer WP-CLI ? (Y/N) [Y]"
    read repInstall

    # Vérification de la réponse
    if [[ $repInstall == 'Y' || $repInstall == 'y' || $repInstall == '' ]]; then
        echo "Installation de ' wp-cli.phar '"
        sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        sudo chmod +x wp-cli.phar
        sudo mv wp-cli.phar /usr/local/bin/wp
    else
        echo "L'installation de WP-CLI est obligatoire, salut !"
        exit
    fi
fi


# Demande des infos de base
echo "Nom de la base de donnée ?"
read dbName
echo "Nom d'utilisateur ?"
read dbUser
echo "Mot de passe ? []"
read dbPass
echo "Hote ? [localhost]"
read dbHost
echo "Prefix tables ? [wp_]"
read dbPrefix
echo "Charset base de donnée ? [utf8]"
read dbCharset

# Vérification des entrées
if [[ $dbHost == '' ]]; then
    dbHost='localhost'
fi

if [[ $dbPrefix == '' ]]; then
    dbPrefix='wp_'
fi

if [[ $dbCharset == '' ]]; then
    dbCharset='utf8'
fi


echo "Code langue pour l'installation ? [en_US]"
read dowLocale
echo "Version de l'installation ? [Dérnière version]"
read dowVersion

if [[ $dowLocale != '' ]]; then
    dowLocale="--locale=${dowLocale}"
fi

if [[ $dowVersion != '' ]]; then
    dowVersion="--version=${dowVersion}"
fi

# Téléchargement
wp core download $dowLocale $dowVersion

# lancement de la config
wp core config --dbname=$dbName --dbuser=$dbUser --dbpass=$dbPass --dbhost=$dbHost --dbprefix=$dbPrefix --dbcharset=$dbCharset

echo "Url de votre site :"
read siteUrl
echo "Titre de votre site :"
read siteTitre
echo "Utilisateur admin"
read siteUser
echo "Mot de passe admin"
read sitePass
echo "Adresse mail"
read siteMail
echo "Envoyé un mail ? (Y/N) [N]"
read siteNotif

# Vérification d'envoie de notification d'installation
if [[ $siteNotif == 'Y' || $siteNotif == 'y' ]]; then
    siteNotif=''
else
    siteNotif='--skip-email'
fi

wp core install --url=$siteUrl --title=$siteTitre --admin_user=$siteUser --admin_password=$sitePass --admin_email=$siteMail $siteNotif

echo ''
echo '##########################   THEMES   ##########################'
echo ''

echo 'Nouveau theme (nom wordpress / chemin zip / url)'
read newTheme 
wp theme install $newTheme --activate
wp theme delete $(wp theme list --status=inactive --field=name)

echo '##########################   PLUGIN   ##########################'
wp plugin delete $(wp plugin list --status=inactive --field=name)

echo 'Nouveau plugin (nom wordpress / chemin zip / url)'
read newPlugin
for plugin in "${newPlugin[@]}"
do
   echo "Activer $plugin ? (Y/N) [Y]"
   read activPlugin

   if [[ $activPlugin == 'Y' || $activPlugin == 'y' || $activPlugin == '' ]]; then
       activate='--activate'
    else
       activate=''
   fi

   wp plugin install $plugin $activPlugin
done