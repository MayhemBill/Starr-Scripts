# Starr-Scripts
A collection of scripts for plex and the starr apps.

All of the scripts in this repo are designed to run from where they located in the root folder for each other, each script relies on a .env file located at the root script folder, a sample .env has been provided so you know what you need to fill out.

# Plex

 ## plex_db_backup.sh
 originally written by [Blasman](https://github.com/blasman) for Unraid, I modified it to be more universal and use notifiarr for notifications and let it run autonomously
 
(copied straight from his repo)

designed for backing up the files that require Plex to be shutdown. By default these are the two main Database files (com.plexapp.plugins.library.db and com.plexapp.plugins.library.blobs.db) and Preferences.xml file. It backs these files up in a sub-folder with a timestamp of the current time to the specified backup directory. This is a script that is usually ran as a nightly cron job during off peak hours of Plex usage.
 ## plex_tarball_backup.sh
 originally written by [Blasman](https://github.com/blasman) for Unraid, I modified it to be more universal and use notifiarr for notifications and let it run autonomously
 
 (copied straight from his repo)
 
 designed for backing up the files that do not require Plex to be shutdown. By default these are the Media and Metadata folders. It backs these files up in a .tar file with a timestamp of the current time to the specified backup directory. This is a script that does not need to be ran as often (ie once a week) as the backups are significantly larger and take much longer.

 ## plexmaintenanceon/off.py 

 written in collaboration with [chazlarson](https://github.com/chazlarson) these are python scripts meant to be run automatically to "turn on/off" plex maintenance schedules. All they really do is change the timing maintenance runs (off changes it to 1-2am, and disables everything, on sets it to 1-9 and enables everything). These were designed to be automatically run to fit a weird schedule with PMM I have setup.

 # Qbit

 ## addtrackers.sh

 I don't know who wrote this, I've been using it for a very long time, and I can't find it anywhere else, so if it's yours claim it in an issue please, I think it's been modified, but I honestly don't remember. This injects a list of trackers into qbittorrent torrent files.

 # Misc

 ## notifiarr.py

 this is just the code snippet from the notifiarr wiki for generating webhooks in python, this is used in most of the SH scripts I have as it's easier than trying to bake it in.



 # Requirements

 Python3

 jq

 curl
