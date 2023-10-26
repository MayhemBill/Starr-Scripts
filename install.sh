#!/bin/bash


echo "This script will help you get the environment setup."

read -p 'Plex IP (not including the http): ' plexurl

sed -i "s/PLEX_URL\=/PLEX_URL\=http:\/\/"$plexurl"/g" sample.env
