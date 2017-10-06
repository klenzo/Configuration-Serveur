#!/bin/bash

# Default VARIABLES
DEPOT_UPDATE=true
PACKAGE_UPGRADE=true

DB_USER="root"
DB_PASSWORD="0000"
DB_HOST="localhost"
DB_CHARSET="utf8"
DB_ALL_PRIVILEGE=false
INTERACTIVE=false
VERBOSE=false

# command to variable : variable=$(command)

while getopts ":u:p:h:c:a i v" option 
do
    case "${option}"
        in
        u) DB_USER=${OPTARG};;
        p) DB_PASSWORD=${OPTARG};;
        h) DB_HOST=${OPTARG};;
        c) DB_CHARSET=${OPTARG};;
        a) DB_ALL_PRIVILEGE=true;;
        i) INTERACTIVE=true;;
        v) VERBOSE=true;;
        \?) echo "${OPTARG} : Option invalide | Usage: $0 [-u DB_USERNAME] [-p DB_PASSWORD] [-h DB_HOST] [-c DB_CHARSET] [-i] [-v]"
                exit 1;;
    esac
done

if [[ $USER == "root" ]]; then
    ROOT_USER="YES"
else
    ROOT_USER="NO"
fi

if [[ $INTERACTIVE == true ]]; then
    echo ""
    read -p "Update Depot ? [Y/n] " r_depot_update
    read -p "Upgrade Package ? [Y/n] " r_package_upgrade

    echo ""
    read -p "Database USER [${DB_USER}] : " iDB_USER
    read -p "Use a database password ? [Y/n] : " iDB_USE_PASSWORD
    if [[ $iDB_USE_PASSWORD == 'Y' || $iDB_USE_PASSWORD == 'y' || $iDB_USE_PASSWORD == '' ]]; then
        read -p "Database PASSWORD [${DB_PASSWORD}] : " iDB_PASSWORD
    else
        iDB_PASSWORD=''
    fi
    read -p "Database HOST [${DB_HOST}] : " iDB_HOST
    read -p "Database CHARSET [${DB_CHARSET}] : " iDB_CHARSET
    
######
    if [[ $r_depot_update == 'Y' || $r_depot_update == 'y' || $r_depot_update == '' ]]; then
        DEPOT_UPDATE=true
    else
        DEPOT_UPDATE=false
    fi
    
    if [[ $r_package_upgrade == 'Y' || $r_package_upgrade == 'y' || $r_package_upgrade == '' ]]; then
        PACKAGE_UPGRADE=true
    else
        PACKAGE_UPGRADE=false
    fi

    if [[ $iDB_USER != $DB_USER ]]; then
        DB_USER=${iDB_USER}
    fi

    if [[ $iDB_PASSWORD != $DB_PASSWORD ]]; then
        DB_PASSWORD=${iDB_PASSWORD}
    fi

    if [[ $iDB_HOST != $DB_HOST ]]; then
        DB_HOST=${iDB_HOST}
    fi

    if [[ $iDB_CHARSET != $DB_CHARSET ]]; then
        DB_CHARSET=${iDB_CHARSET}
    fi

fi

echo "
### CONFIGURATION ###

    VERBOSE             : ${VERBOSE}
    INTERACTIVE         : ${INTERACTIVE}
    DB_USER             : ${DB_USER}
    DB_PASSWORD         : ${DB_PASSWORD}
    DB_HOST             : ${DB_HOST}
    DB_CHARSET          : ${DB_CHARSET}
    DB_ALL_PRIVILEGE    : ${DB_ALL_PRIVILEGE}
    ROOT                : ${ROOT_USER}

#####################"

source ./functions.sh

if [[ $VERBOSE == true ]]; then
    echo ""
    depot_update $DEPOT_UPDATE
    package_upgrade $PACKAGE_UPGRADE

    echo "
    Installation package ' debconf-utils ' ...
    "
    package_install debconf-utils -y
else
    depot_update $DEPOT_UPDATE > /dev/null
    package_upgrade $PACKAGE_UPGRADE -y > /dev/null

    package_install debconf-utils -y > /dev/null
fi


echo "
######## END ########"
exit 0