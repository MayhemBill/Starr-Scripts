#!/bin/bash

<<<<<<< HEAD

echo "This script will help you get the environment setup."

read -p 'Plex IP (not including the http): ' plexurl

sed -i "s/PLEX_URL\=/PLEX_URL\=http:\/\/"$plexurl"/g" sample.env
=======
#Functions
echo_ts() { local ms=${EPOCHREALTIME#*.}; printf "[%(%Y_%m_%d)T %(%H:%M:%S)T.${ms:0:3}] $@\\n"; }

#Script start
echo "This script will help you get the environment setup."
echo "First I'm going to grab some variables"

echo_ts "Finding Python"
python_executable="$(command -v python3)"

if [[ -z $python_executable ]]; then
	echo_ts "You don't have python installed."
    echo_ts "would you like me to install it for you?"
	read -p '(yes/no): ' installpython
    if [[ $installpython = yes ]]; then sudo apt install python3 -y
    fi
    python_executable="$(command -v python3)"
fi
echo_ts "Python Found!"
sed -i "s|PYTHON_PATH\=|PYTHON_PATH\=$python_executable|g" sample.env

echo_ts "Finding jq"

jq_executable="$(command -v jq)"

if [[ -z $jq_executable ]]; then
	echo_ts "You don't have jq installed."
    echo_ts "would you like me to install it for you?"
	read -p '(yes/no): ' installjq
    if [[ $installjq = yes ]]; then sudo apt install jq -y
    fi
    jq_executable="$(command -v jq)"
fi
echo_ts "Found jq!"

echo_ts "Finding cURL"

curl_executable="$(command -v curl)"

if [[ -z $curl_executable ]]; then
	echo_ts "You don't have curl installed."
    echo_ts "would you like me to install it for you?"
	read -p '(yes/no): ' installcurl
    if [[ $installjq = yes ]]; then sudo apt install curl -y
    fi
    curl_executable="$(command -v curl)"
fi
echo_ts "Found cURL"

echo_ts "Time for some inputs"
#Directories first
read -p 'Backup Directory: ' backupdir
sed -i "s|BACKUP_DIR\=|BACKUP_DIR\=$backupdir|g" sample.env
read -p 'Scripts Directory: ' scriptdir
sed -i "s|WORKING_DIR\=WORKING_DIR\=$scriptdir|g" sample.env

echo_ts "Now Plex and the Starrs"
#Plex is required, so no options to disable.
read -p 'Plex URL: ' plexurl
sed -i "s|PLEX_URL\=|PLEX_URL\=$plexurl|g" sample.env
read -p 'Plex Token: ' plextoken
sed -i "s|PLEX_TOKEN\=|PLEX_TOKEN\=$plextoken|g" sample.env
read -p 'Plex Config Directory: ' plexdir
sed -i "s|PLEX_DIR\=|PLEX_DIR\=$plexdir|g" sample.env
read -p 'Plex Container name: ' plexcontainer
sed -i "s|PLEX_DOCKER_NAME\=|PLEX_DOCKER_NAME\=$plexcontainer|g" sample.env

#QbitTorrent is optional, so everything depends on enabled or not
read -p 'Use QbitTorrent?:(true/false) ' qbitenabled
sed -i "s|QBIT_ENABLED\=|QBIT_ENABLED\=$qbitenabled|g" sample.env

if [[ $qbitenabled = true ]]; then
    read -p 'QBitTorrent URL: ' qbiturl
    sed -i "s|QBIT_URL\=|QBIT_URL\=$qbiturl|g" sample.env
    read -p 'QBitTorrent Port: ' qbitport
    sed -i "s|QBIT_PORT\=|QBIT_PORT\=$qbitport|g" sample.env
    read -p 'QBitTorrent Username: ' qbituser
    sed -i "s|QBIT_USER\=|QBIT_USER\=$qbituser|g" sample.env
    read -p 'QBitTorrent password: ' qbitpass
    sed -i "s|QBIT_PASS\=|QBIT_PASS\=$qbitpass|g" sample.env
fi

#Lidarr is optional, so everything depends on enabled or not
read -p 'Use Lidarr?:(true/false) ' lidarrenabled
sed -i "s|LIDARR_ENABLED\=|LIDARR_ENABLED\=$lidarrenabled|g" sample.env

if [[ $lidarrenabled = true ]]; then
    read -p 'Lidarr URL: ' lidarrurl
    sed -i "s|LIDARR_URL\=|LIDARR_URL\=$lidarrurl|g" sample.env
    read -p 'Lidarr Container Directory: ' lidarrcontainer
    sed -i "s|LIDARR_DIR\=|LIDARR_DIR\=$lidarrcontainer|g" sample.env
    read -p 'Lidarr Container Name: ' lidarrname
    sed -i "s|LIDARR_DOCKER_NAME\=|LIDARR_DOCKER_NAME\=$lidarrname|g" sample.env
fi

#Overseerr is optional, so everything depends on enabled or not
read -p 'Use Overseerr?:(true/false) ' overseerrenabled
sed -i "s|OVERSEERR_ENABLED\=|OVERSEERR_ENABLED\=$overseerrenabled|g" sample.env

if [[ $overseerrenabled = true ]]; then
    read -p 'Overseerr URL: ' overseerrurl
    sed -i "s|OVERSEERR_URL\=|OVERSEERR_URL\=$overseerrrurl|g" sample.env
    read -p 'Overseerr Container Directory: ' overseerrcontainer
    sed -i "s|OVERSEERR_DIR\=|OVERSEERR_DIR\=$overseerrcontainer|g" sample.env
    read -p 'Overseerr Container Name: ' overseerrname
    sed -i "s|OVERSEERR_DOCKER_NAME\=|OVERSEERR_DOCKER_NAME\=$overseerrname|g" sample.env
fi

#Prowlarr is optional, so everything depends on enabled or not
read -p 'Use Prowlarr?:(true/false) ' prowlarrenabled
sed -i "s|PROWLARR_ENABLED\=|PROWLARR_ENABLED\=$prowlarrenabled|g" sample.env

if [[ $prowlarrenabled = true ]]; then
    read -p 'Prowlarr URL: ' prowlarrurl
    sed -i "s|PROWLARR_URL\=|PROWLARR_URL\=$prowlarrrurl|g" sample.env
    read -p 'Prowlarr Container Directory: ' prowlarrcontainer
    sed -i "s|PROWLARR_DIR\=|PROWLARR_DIR\=$prowlarrcontainer|g" sample.env
    read -p 'Prowlarr Container Name: ' prowlarrname
    sed -i "s|PROWLARR_DOCKER_NAME\=|PROWLARR_DOCKER_NAME\=$prowlarrname|g" sample.env
fi


#Radarr is optional, so everything depends on enabled or not
read -p 'Use Radarr?:(true/false) ' radarrenabled
sed -i "s|RADARR_ENABLED\=|RADARR_ENABLED\=$radarrenabled|g" sample.env

if [[ $radarrenabled = true ]]; then
    read -p 'Radarr URL: ' radarrurl
    sed -i "s|RADARR_URL\=|RADARR_URL\=$radarrrurl|g" sample.env
    read -p 'Radarr Container Directory: ' radarrcontainer
    sed -i "s|RADARR_DIR\=|RADARR_DIR\=$radarrcontainer|g" sample.env
    read -p 'Radarr Container Name: ' radarrname
    sed -i "s|RADARR_DOCKER_NAME\=|RADARR_DOCKER_NAME\=$radarrname|g" sample.env
fi

#Sonarr is optional, so everything depends on enabled or not
read -p 'Use Sonarr?:(true/false) ' sonarrenabled
sed -i "s|SONARR_ENABLED\=|SONARR_ENABLED\=$sonarrenabled|g" sample.env

if [[ $sonarrenabled = true ]]; then
    read -p 'Sonarr URL: ' sonarrurl
    sed -i "s|SONARR_URL\=|SONARR_URL\=$sonarrrurl|g" sample.env
    read -p 'Sonarr Container Directory: ' sonarrcontainer
    sed -i "s|SONARR_DIR\=|SONARR_DIR\=$sonarrcontainer|g" sample.env
    read -p 'Sonarr Container Name: ' sonarrname
    sed -i "s|SONARR_DOCKER_NAME\=|SONARR_DOCKER_NAME\=$sonarrname|g" sample.env
fi

#Notifiarr is optional, so everything depends on enabled or not
read -p 'Use Notifiarr?:(true/false) ' notifiarrenabled
sed -i "s|USE_NOTIFIARR\=|USE_NOTIFIARR\=$notifiarrenabled|g" sample.env

if [[ $notifiarrenabled = true ]]; then
    read -p 'Notifiarr API: ' notifiarrapikey
    sed -i "s|NOTIFIARR_APIKEY\=|NOTIFIARR_APIKEY\=$notifiarrapikey|g" sample.env
    read -p 'Notifiarr Channel: ' notifiarrchannel
    sed -i "s|NOTIFIARR_CHANNEL\=|NOTIFIARR_CHANNEL\=$notifiarrchannel|g" sample.env
    read -p 'Notifiarr Icon: ' notifiarricon
    sed -i "s|ICON\=|ICON\=$notifiaricon|g" sample.env
fi

mv "sample.env" ".env"
echo_ts "Looks like everything is setup now, exiting.."
exit 0
>>>>>>> 71d51a1 (added install script to set the environment before anything else)
