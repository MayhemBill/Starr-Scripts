#!/bin/bash

#Load .env before anything else
if [ -f "$(dirname "$BASH_SOURCE")"/../.env ]
then
  export $(cat "$(dirname "$BASH_SOURCE")"/../.env | sed 's/#.*//g' | xargs)
fi


if [[ $LIDARR_ENABLED = true ]]; then source "$(dirname "$BASH_SOURCE")"/lidarr.sh; fi
if [[ $RADARR_ENABLED = true ]]; then source "$(dirname "$BASH_SOURCE")"/radarr.sh; fi
if [[ $SONARR_ENABLED = true ]]; then source "$(dirname "$BASH_SOURCE")"/sonarr.sh; fi
if [[ $PROWLARR_ENABLED = true ]]; then source "$(dirname "$BASH_SOURCE")"/prowlarr.sh; fi









if [[ $RADARR_ENABLED = true ]]; then radarr_notification="\"Radarr Backup Size\": \"$(ls -lh "$RADARR_TAR_FILE" | awk '{ print $5 }')\""; else radarr_notification=""; fi
if [[ $SONARR_ENABLED = true ]]; then sonarr_notification="\"Sonarr Backup Size\": \"$(ls -lh "$SONARR_TAR_FILE" | awk '{ print $5 }')\""; else sonarr_notification=""; fi
if [[ $LIDARR_ENABLED = true ]]; then lidarr_notification="\"Lidarr Backup Size\": \"$(ls -lh "$LIDARR_TAR_FILE" | awk '{ print $5 }')\""; else lidarr_notification=""; fi
if [[ $PROWLARR_ENABLED = true ]]; then prowlarr_notification="\"Prowlarr Backup Size\": \"$(ls -lh "$PROWLARR_TAR_FILE" | awk '{ print $5 }')\""; else prowlarr_notification=""; fi
#function to check and send webhook
send_notifiarr_webhook() {
    if [ $USE_NOTIFIARR = true ]; then
        echo_ts "[SENDING NOTIFICATION]"
        python3 "$(dirname "$BASH_SOURCE")"/../misc/notifiarr.py -e "Starr DB Backup" -c 1164585523348783104 -m "FFA500" -t "Backup Success" -g "[{$radarr_notification}, {$sonarr_notification}, {$lidarr_notification}, {$prowlarr_notification}]" -b "Backup was created at '$BACKUP_DIR'" -a "$ICON" -z "MYHM.Space"
    fi
}

# Send backup completed notification.
cd $WORKING_DIR
send_notifiarr_webhook


exit 0
