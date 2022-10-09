#!/bin/bash

############################################################
# Version et Aide                                          #
############################################################
version()
{
   # Affiche la version
   version=1.0.0
   echo "Version du script" $version
   echo
   exit 1
}

usage()
{
   # Display Help
   echo "Programme de gestion de la synchronisation des projets Opticore (1.x et 2.x)."
   echo
   echo "Syntax: optimind [-h|x|l|t||v] [-s project_name]"
   echo "options:"
   echo "h     Affiche l'aide."
   echo "s     Démarre la synchronisation d'un projet : 'project_name' obligatoire."
   echo "x     Stop la synchronisation"
   echo "l     Liste les commandes / projets possibles"
   echo "t     Affiche les logs d'utilisation."
   echo "v     Numéro de version."
   echo "u     Une seule exécution."
   echo
   exit 1
}


############################################################
# Changement de projet                                     #
############################################################
log()
{
	if [ -f /root/msync.log ]
	then
	    tail -10 /root/msync.log
	else
		echo "Aucun log msync.log"
	fi

	sleep 1
	exit 1
}

list()
{
	msync.sh -l

	sleep 1
	exit 1
}

stop()
{
	pid_sync=`ps -C msync.sh -o pid=`
	if [ ! -z "$pid_sync" ]
	then
	    # Kill ancien process
		kill -9 $pid_sync
		kill -9 `ps -C rsync -o pid=` > /dev/null 2> /dev/null
		echo "Arrêt de tous les processus de synchro avec succès."
	fi
}

start()
{
	# Arret de la synchronisation précédente
	stop

	echo "Démarrage du projet ${1}"

	if [ -z $1 ]
	then
	    # Aucun nom
	    echo "Aucun nom de projet indiqué"
		exit 1
	fi

	sleep 1

	if [ -z $2 ]
	then
	    # Lancement de la synchronisation
		msync.sh $1 & 
	else
		if [ ${2} -eq 1 ]
	    then
			# Lancement de la synchronisation unique
			msync.sh -u $1 &
	    fi
	fi

	sleep 1
}

############################################################
# Traitement selon les options                             #
############################################################
while getopts "hvltxus:" option; do
    case "${option}" in
        u)
            u=1
            ;;
        s)
            s=${OPTARG}
            ;;
        x)
            stop
            exit 1
            ;;
        l)
            list
            ;;
        t)
            log
            ;;
        v)
            version
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
if [ -z "${s}" ]; then
    usage
fi

start $s $u

exit 0
