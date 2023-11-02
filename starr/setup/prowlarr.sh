#!/bin/bash

#Load .env before anything else
if [ -f "$(dirname "$BASH_SOURCE")"/../.env ]
then
  export $(cat "$(dirname "$BASH_SOURCE")"/../.env | sed 's/#.*//g' | xargs)
fi

#get API key from the radarr config
prowlarrpikey=$(xmllint --xpath 'string(/Config/ApiKey)' $PROWLARR_DIR/config.xml)

#create the notifiarr connect if using notifiarr
if [[ $notifiarrenabled = true ]]
then
  curl -X POST $PROWLARR_URL/api/v3/notification?apikey=$prowlarrpikey -H "Content-Type: application/json" -d "{\"onGrab\":true,\"onDownload\":true,\"onUpgrade\":true,\"onRename\":false,\"onMovieAdded\":true,\"onMovieDelete\":true,\"onMovieFileDelete\":true,\"onMovieFileDeleteForUpgrade\":false,\"onHealthIssue\":true,\"onHealthRestored\":false,\"onApplicationUpdate\":true,\"onManualInteractionRequired\":false,\"supportsOnGrab\":true,\"supportsOnDownload\":true,\"supportsOnUpgrade\":true,\"supportsOnRename\":true,\"supportsOnMovieAdded\":true,\"supportsOnMovieDelete\":true,\"supportsOnMovieFileDelete\":true,\"supportsOnMovieFileDeleteForUpgrade\":true,\"supportsOnHealthIssue\":true,\"supportsOnHealthRestored\":true,\"supportsOnApplicationUpdate\":true,\"supportsOnManualInteractionRequired\":true,\"includeHealthWarnings\":false,\"name\":\"Notifiarr\",\"fields\":[{\"name\":\"aPIKey\",\"value\":\"${NOTIFIARR_APIKEY}\"}],\"implementationName\":\"Notifiarr\",\"implementation\":\"Notifiarr\",\"configContract\":\"NotifiarrSettings\",\"infoLink\":\"https://wiki.servarr.com/radarr/supported#notifiarr\",\"tags\":[]}"
fi