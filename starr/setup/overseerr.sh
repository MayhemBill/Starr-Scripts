#!/bin/bash

#Load .env before anything else
if [ -f "$(dirname "$BASH_SOURCE")"/../.env ]
then
  export $(cat "$(dirname "$BASH_SOURCE")"/../.env | sed 's/#.*//g' | xargs)
fi

#get API key from the overseerr config
overseerrapikey=$(jq .main.apiKey $OVERSEERR_DIR/settings.json)


#create the notifiarr connect if using notifiarr

if [[ $notifiarrenabled = true ]]
then
  curl -X POST https://overseerr.myhm.space/api/v1/settings/notifications/webhook -H "Content-Type: application/json" -H "X-Api-Key: $overseerrapikey" -d "{\"enabled\":true,\"types\":16,\"options\":{\"webhookUrl\":\"https://notifiarr.com/api/v1/notification/overseerr/$NOTIFIARR_APIKEY\",\"jsonPayload\":\"{\\\"notification_type\\\":\\\"{{notification_type}}\\\",\\\"event\\\":\\\"{{event}}\\\",\\\"subject\\\":\\\"{{subject}}\\\",\\\"message\\\":\\\"{{message}}\\\",\\\"image\\\":\\\"{{image}}\\\",\\\"{{media}}\\\":{\\\"media_type\\\":\\\"{{media_type}}\\\",\\\"tmdbId\\\":\\\"{{media_tmdbid}}\\\",\\\"tvdbId\\\":\\\"{{media_tvdbid}}\\\",\\\"status\\\":\\\"{{media_status}}\\\",\\\"status4k\\\":\\\"{{media_status4k}}\\\"},\\\"{{request}}\\\":{\\\"request_id\\\":\\\"{{request_id}}\\\",\\\"requestedBy_email\\\":\\\"{{requestedBy_email}}\\\",\\\"requestedBy_username\\\":\\\"{{requestedBy_username}}\\\",\\\"requestedBy_avatar\\\":\\\"{{requestedBy_avatar}}\\\"},\\\"{{issue}}\\\":{\\\"issue_id\\\":\\\"{{issue_id}}\\\",\\\"issue_type\\\":\\\"{{issue_type}}\\\",\\\"issue_status\\\":\\\"{{issue_status}}\\\",\\\"reportedBy_email\\\":\\\"{{reportedBy_email}}\\\",\\\"reportedBy_username\\\":\\\"{{reportedBy_username}}\\\",\\\"reportedBy_avatar\\\":\\\"{{reportedBy_avatar}}\\\"},\\\"{{comment}}\\\":{\\\"comment_message\\\":\\\"{{comment_message}}\\\",\\\"commentedBy_email\\\":\\\"{{commentedBy_email}}\\\",\\\"commentedBy_username\\\":\\\"{{commentedBy_username}}\\\",\\\"commentedBy_avatar\\\":\\\"{{commentedBy_avatar}}\\\"},\\\"{{extra}}\\\":[]}\"}}"
fi