import os
from dotenv import load_dotenv
from plexapi.myplex import MyPlexAccount
from plexapi.server import PlexServer
import requests
import json
ENVPATH = os.path.abspath(os.path.join(os.path.dirname( __file__ ), '..', '.env'))
load_dotenv(ENVPATH)
# Replace with your Plex server URL, token, and username/password
PLEX_URL = os.getenv('PLEX_URL')
PLEX_TOKEN = os.getenv('PLEX_TOKEN')
NOTIFIARR_APIKEY = os.getenv('NOTIFIARR_APIKEY')
NOTIFIARR_URL = f"https://notifiarr.com/api/v1/notification/passthrough/{NOTIFIARR_APIKEY}"
NOTIFIARR_CHANNEL = os.getenv('NOTIFIARR_CHANNEL')
SCRIPT_NAME = "Plex Maintenance Off"
ICON = os.getenv('ICON')
# Create a PlexServer object
plex = PlexServer(PLEX_URL, PLEX_TOKEN)

# Specify the maintenance window time
# (default: 5; choices: 0:Midnight|1:1 am|2:2 am|3:3 am|4:4 am|5:5 am|6:6 am|7:7 am|8:8 am|9:9 am|10:10 am|11:11 am|12:Noon|13:1 pm|14:2 pm|15:3 pm|16:4 pm|17:5 pm|18:6 pm|19:7 pm|20:8 pm|21:9 pm|22:10 pm|23:11 pm)
maintenance_start_time = 1
maintenance_end_time = 2
maintenance_status = False

# Get the server settings
server_settings = plex.settings

# Update the maintenance window settings
server_settings.get('butlerStartHour').set(maintenance_start_time)
server_settings.get('butlerEndHour').set(maintenance_end_time)

server_settings.get('butlerTaskCleanOldBundles').set(maintenance_status)
server_settings.get('butlerTaskCleanOldCacheFiles').set(maintenance_status)
server_settings.get('butlerTaskDeepMediaAnalysis').set(maintenance_status)
server_settings.get('butlerTaskOptimizeDatabase').set(maintenance_status)
server_settings.get('butlerTaskRefreshEpgGuides').set(maintenance_status)
server_settings.get('butlerTaskRefreshLibraries').set(maintenance_status)
server_settings.get('butlerTaskRefreshLocalMedia').set(maintenance_status)
server_settings.get('butlerTaskRefreshPeriodicMetadata').set(maintenance_status)
server_settings.get('butlerTaskUpgradeMediaAnalysis').set(maintenance_status)

server_settings.save()

print(f"Maintenance window set from {maintenance_start_time} to {maintenance_end_time}")

notifiarr_payload = {
    'notification': {
        'update': False,
        'name': SCRIPT_NAME,
        'event': 0
    },
    'discord': {
        'color': 'D2042D',
        'text': {
            'title': 'Plex maintenance update',
            'icon': ICON,
            'fields': [
                {
                    "title": "Start:",
                    "text": maintenance_start_time,
                    "inline": True
                }, {
                    "title": "End:",
                    "text": maintenance_end_time,
                    "inline": True
                }, {
                    "title": "Operation Status",
                    "text": f"{maintenance_status}",
                    "inline": False
                }
            ]
        },
        'images': {
            'thumbnail': ICON
    },
        'ids': {
            'channel': NOTIFIARR_CHANNEL
        }
    }
}

r = requests.post(f'https://notifiarr.com/api/v1/notification/passthrough/{NOTIFIARR_APIKEY}', data=json.dumps(notifiarr_payload), headers={'Content-type': 'application/json', 'Accept': 'text/plain'})
