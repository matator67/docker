#!/bin/bash

unique=0
verbose=0

# Tableau associatif des noms des projets et des répertoires dans www/
declare -A projets=(
    ['sites']="sites-symfony"
    ['atrium']="chambredhotesfrejus.fr"
    ['gite']="gite-le-jardin-emma.fr"
    ['a2p']="a2p-deco.fr"
)

############################################################
# Liste                                                    #
############################################################
list()
{
   # Affiche la version
    echo "Affiche la liste des projets"
    echo
    for index in ${!projets[@]}
    do
        echo -e "\t$index\t${projets[$index]}"
    done

       exit 1
}

############################################################
# Traitement selon les options                             #
############################################################
while getopts "uvl" option; do
    case "${option}" in
        u)
            unique=1
            ;;
        v)
            verbose=1
            ;;
        l)
            list
            ;;
    esac
done

nom=$1
if [ ${verbose} -eq 1 -a $nom == "-v" ]
then
    nom=$2
fi
if [ ${unique} -eq 1 -a $nom == "-u" ]
then
    nom=$2
fi
repertoire=${projets[$nom]}
if [ -z $repertoire ]
then
    echo "Projet $nom non paramétré !"
    exit 1
fi

if [ ! -d "/var/www2/$repertoire/" ]
then
    echo "Le répertoire source $repertoire n'existe pas !"
    exit 1
fi

# Project
echo Lancement du projet $nom : $repertoire
echo `date -u` Lancement du projet $nom : $repertoire > /root/osync.log

RSYNC_INIT="rsync -azC --update --include=.env --include=.env* --include=storage/* --include=public/* --exclude=.merge_file* --exclude=templates/components --exclude-from=/var/www2/$repertoire/.gitignore --log-file=/root/rsync.log /var/www2/$repertoire/ /var/www/$repertoire/"
RSYNC="rsync -azC --update --delete --include=.env --include=.env* --exclude=storage/* --exclude=public/* --exclude=.merge_file* --exclude=templates/components --exclude-from=/var/www2/$repertoire/.gitignore --log-file=/root/rsync.log /var/www2/$repertoire/ /var/www/$repertoire/"
RSYNC_ENTITY="rsync -a --update --include=src/Entity/* --exclude=* --log-file=/root/rsync.log /var/www/$repertoire/ /var/www2/$repertoire/"

TIME=`date +%s`
if [ ${verbose} -eq 1 ]
then
    echo -n `date +"%T GMT"` [Init $nom]
fi
echo `date +"%T GMT"` [Init $nom] >> /root/osync.log

# Synchronisation initiale
$RSYNC_INIT >> /root/osync.log

if [ ${verbose} -eq 1 ]
then
    echo -e "\t"durée $(($(date +%s)-$TIME))sec
fi
echo -e "\t"Durée $(($(date +%s)-$TIME))sec >> /root/osync.log

# while inotifywait -r -e modify,create,delete,move /var/www2/my.optimind.com/;
# do
# 	echo "DETECTE CHANGEMENT"
#     sleep 1
# done

while true
do
    # Log des traitements
    TIME=`date +%s`
    if [ ${verbose} -eq 1 ]
    then
        echo -n `date +"%T GMT"` [$nom]
    fi
    echo `date +"%T GMT"` [$nom] >> /root/osync.log

    # Synchronise les entités
    # $RSYNC_ENTITY >> /root/osync.log

    # Synchronise les fichiers vers Docker
    $RSYNC >> /root/osync.log

    if [ ${verbose} -eq 1 ]
    then
        echo -e "\t"durée $(($(date +%s)-$TIME))sec
    fi
    echo -e "\t"Durée $(($(date +%s)-$TIME))sec >> /root/osync.log

    sleep 1

    if [ ${unique} -eq 1 ]
    then
        echo -e Fin... >> /root/osync.log
        exit 0
    fi
done

exit 0
