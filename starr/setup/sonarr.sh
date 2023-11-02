#!/bin/bash

#Load .env before anything else
if [ -f "$(dirname "$BASH_SOURCE")"/../.env ]
then
  export $(cat "$(dirname "$BASH_SOURCE")"/../.env | sed 's/#.*//g' | xargs)
fi

#get API key from the sonarr config
sonarrapikey=$(xmllint --xpath 'string(/Config/ApiKey)' $SONARR_DIR/config.xml)

#add tracker injector to Radarr
script_path='/mnt/scripts/qbit/addqbittrackers.sh'

#create the connect event in sonarr for the injector script
curl -X POST $SONARR_URL/api/v3/notification?apikey=$sonarrapikey -H "Content-Type: application/json" -d "{\"onGrab\":true,\"onDownload\":false,\"onUpgrade\":true,\"onRename\":false,\"onMovieAdded\":false,\"onMovieDelete\":false,\"onMovieFileDelete\":false,\"onMovieFileDeleteForUpgrade\":true,\"onHealthIssue\":false,\"onHealthRestored\":false,\"onApplicationUpdate\":false,\"onManualInteractionRequired\":false,\"supportsOnGrab\":true,\"supportsOnDownload\":true,\"supportsOnUpgrade\":true,\"supportsOnRename\":true,\"supportsOnMovieAdded\":true,\"supportsOnMovieDelete\":true,\"supportsOnMovieFileDelete\":true,\"supportsOnMovieFileDeleteForUpgrade\":true,\"supportsOnHealthIssue\":true,\"supportsOnHealthRestored\":true,\"supportsOnApplicationUpdate\":true,\"supportsOnManualInteractionRequired\":true,\"includeHealthWarnings\":false,\"name\":\"Custom Script\",\"fields\":[{\"name\":\"path\",\"value\":\"${script_path}\"},{\"name\":\"arguments\"}],\"implementationName\":\"Custom Script\",\"implementation\":\"CustomScript\",\"configContract\":\"CustomScriptSettings\",\"infoLink\":\"https:\/\/wiki.servarr.com\/sonarr\/supported#customscript\",\"tags\":[]}"

#create the notifiarr connect if using notifiarr

if [[ $notifiarrenabled = true ]]
then
  curl -X POST $SONARR_URL/api/v3/notification?apikey=$sonarrapikey -H "Content-Type: application/json" -d "{\"onGrab\":true,\"onDownload\":true,\"onUpgrade\":true,\"onRename\":false,\"onMovieAdded\":true,\"onMovieDelete\":true,\"onMovieFileDelete\":true,\"onMovieFileDeleteForUpgrade\":false,\"onHealthIssue\":true,\"onHealthRestored\":false,\"onApplicationUpdate\":true,\"onManualInteractionRequired\":false,\"supportsOnGrab\":true,\"supportsOnDownload\":true,\"supportsOnUpgrade\":true,\"supportsOnRename\":true,\"supportsOnMovieAdded\":true,\"supportsOnMovieDelete\":true,\"supportsOnMovieFileDelete\":true,\"supportsOnMovieFileDeleteForUpgrade\":true,\"supportsOnHealthIssue\":true,\"supportsOnHealthRestored\":true,\"supportsOnApplicationUpdate\":true,\"supportsOnManualInteractionRequired\":true,\"includeHealthWarnings\":false,\"name\":\"Notifiarr\",\"fields\":[{\"name\":\"aPIKey\",\"value\":\"${NOTIFIARR_APIKEY}\"}],\"implementationName\":\"Notifiarr\",\"implementation\":\"Notifiarr\",\"configContract\":\"NotifiarrSettings\",\"infoLink\":\"https://wiki.servarr.com/sonarr/supported#notifiarr\",\"tags\":[]}"
fi