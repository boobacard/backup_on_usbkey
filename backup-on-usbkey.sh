#!/bin/bash
#################################################################################
# Description: Permet de faire un backup du home avec rsync sur un media USB.   #
# /!\ Une mauvaise utilisation de rsync peut entrainer une perte de donnees.    #
# Dependances: rsync;                                                           #
# Auteur:  Boubacar                                                             #
# Licence: GPL                                                                  #
# Version: 0.4                                                                  #
# Infos: https://bakari.qc.lu                                                   #
#################################################################################
#_______________PARAMETRES ET OPTIONS DE CONFIGURATION DU SCRIPTS_______________#
# Entrez le chemin vers la clé USB, disque dur ou autre (sans slash à la fin):
USB=/media/Boubacar/backup
# Dossier source de la sauvegarde (Default: /home/votre-nom):
SOURCE=~/
# Dossier de destination de la sauvegarde (Default: /media/clef_USB/home-votre_nom):
DIRBAK=$USB/home-$USER/
# Démonter automatiquement le support USB la fin du script ? ("Y"=oui; ""=non):
DEMONTER=""
# Répondre automatiquement à la question pour ne pas avoir à intervenir ? ("Y"=oui; ""=non):
YESNO=""
# Nom et destination du fichier de log (Defaut: /media/clef_USB/home-votre_nom/.rsync.log):
LOG="$DIRBAK".rsync.log
# Options de rsync (Voir man rsync):
OPTIONS="-dirtoq --delete --exclude=.* --log-file="$LOG""
#################################################################################
#____________________VARIABLES DE MISE EN FORME DU TEXTE________________________#
JAUNE="\E[33;40m" # Texte jaune;fond gris
BLANC="\E[37;40m" # Texte blanc;fond gris
ROUGE="\E[31;40m" # Texte rouge;fond gris
ALIGNR="\e[$((${COLUMNS:-"$(tput cols)"}-10))G" # Aligner le texte à droite
OK="$ALIGNR [ OK ]" # Affiche [ OK ] quand ça fonctionne
FAIL="$ALIGNR $ROUGE [ FAIL ] $BLANC" # Affiche [ fail ] en cas d'erreur
#################################################################################
#____________________FONCTIONS DE SORTIES DU SCRIPT_____________________________#
function terminer0 {
	echo -e "* Sauvegarde complète de $SOURCE $OK"
	if [ "$DEMONTER" = "Y" ]; then
		sleep 1 && umount $USB
		if [ "$?" != "0" ]; then
			echo -e "* Démontage de $USB $FAIL"
		else
			echo -e "* Démontage de $USB $OK"
		fi
	fi
	echo -e $JAUNE
	echo "* Appuyer sur <Entrer> pour quitter..."
	read
	exit 0
}
function terminer1 {
	echo -e "* Sauvegarde complète de $SOURCE $FAIL"
	echo -e $JAUNE
	echo "* Appuyer sur <Entrer> pour quitter..."
	read
	exit 1
}
#################################################################################
#___________________________FONCTION DE SAUVEGARDE_____________________________#
function sauvegarde {
	echo -e "* Chemin du log : $LOG"
	echo -e "* Sauvegarde en cours..."
	echo -e "========`date`========" > "$LOG"
	rsync $OPTIONS $SOURCE $DIRBAK
	if [ "$?" != "0" ]; then
		echo -e "* Sauvegarde complète de $SOURCE $FAIL"
		while [ "$LOGYESNO" = "" ]; do
			echo -e $JAUNE # Change de couleur avant la question
			echo -e -n "* Afficher le fichier log ? (Y/N) "
			read YESNOLOG
			echo -e $BLANC # Change de couleur après la question
			if ( [ "$YESNOLOG" = "N" ] || [ "$YESNOLOG" = "n" ] ); then
				clear
				terminer1
			elif ( [ "$YESNOLOG" = "Y" ] || [ "$YESNOLOG" = "y" ] ); then
				clear
				echo "* Ouverture du fichier log..."
				sleep 2 && cat $LOG
				terminer1
			else
				clear
				echo -e $JAUNE
				echo "* Répondre par <Y> ou <N>"
				echo -e $BLANC
				sleep 2 && clear
				YESNOLOG=""
			fi
		done
	else
		terminer0
	fi
}
#################################################################################
#____________________DEBUT DU SCRIPT____________________________________________#
echo -e $BLANC && clear # Change de couleur et nettoie l'affichage
if [ ! -d "$USB/" ]; then # Check si le support USB est branché
	echo -e "* Accès à $USB $FAIL"
	terminer1
else
	echo -e "* Accès à $USB $OK"
fi
if [ ! -d "$DIRBAK" ]; then # Check si le dossier de destination existe
	mkdir $DIRBAK
	if [ "$?" != "0" ]; then
		echo -e "* mkdir "$DIRBAK" $FAIL"
		terminer1
	else
		echo -e "* mkdir "$DIRBAK" $OK"
	fi
else
	echo -e "* Accès à $DIRBAK $OK"
fi

while [ "$YESNO" = "" ] || [ "$YESNO" = "Y" ]; do # Démarrage de la sauvegarde
	if [ "$YESNO" = "Y" ]; then
		sauvegarde
	fi
	echo -e $JAUNE # Change de couleur avant la question
	echo -e -n "* Démarrer la sauvegarde ? (Y/N) "
	read YESNO
	echo -e $BLANC # Change de couleur après la question
	if ( [ "$YESNO" = "N" ] || [ "$YESNO" = "n" ] ); then
		echo "* Sauvegarde annulée..."
		terminer1
	elif ( [ "$YESNO" = "Y" ] || [ "$YESNO" = "y" ] ); then
		sauvegarde
	else
		clear
		echo -e $JAUNE
		echo "* Répondre par <Y> ou <N>"
		echo -e $BLANC
		sleep 2 && clear
		YESNO=""
	fi
done
