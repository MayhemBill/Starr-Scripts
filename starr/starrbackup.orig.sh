#Load .env before anything else
if [ -f "$(dirname "$BASH_SOURCE")"/../.env ]
then
  export $(cat "$(dirname "$BASH_SOURCE")"/../.env | sed 's/#.*//g' | xargs)
fi
#########################################################
################### USER CONFIG BELOW ###################
#########################################################

HOURS_TO_KEEP_BACKUPS_FOR="95"  # Delete backups older than this many hours. Comment out or delete to disable.
PERMISSIONS="777"  # Set to any 3 or 4 digit value to have chmod set those permissions on the final tar file. Comment out or delete to disable.

#----------- OPTIONAL ADVANCED CONFIG BELOW ------------#
RADARR_TARFILE_TEXT="Radarr-Backup"
SONARR_TARFILE_TEXT="Sonarr-Backup"
LIDARR_TARFILE_TEXT="Lidarr-Backup"
PROWLARR_TARFILE_TEXT="Prowlarr-Backup"

TIMESTAMP() { date +"%Y_%m_%d"; }
COMPLETE_RADARR_TARFILE_NAME() { echo "[$(TIMESTAMP)] $RADARR_TARFILE_TEXT.tar"; }
COMPLETE_SONARR_TARFILE_NAME() { echo "[$(TIMESTAMP)] $SONARR_TARFILE_TEXT.tar"; }
COMPLETE_LIDARR_TARFILE_NAME() { echo "[$(TIMESTAMP)] $LIDARR_TARFILE_TEXT.tar"; }
COMPLETE_PROWLARR_TARFILE_NAME() { echo "[$(TIMESTAMP)] $PROWLARR_TARFILE_TEXT.tar"; }
RADARR_TAR_COMMAND() {
    tar -cf "$RADARR_TAR_FILE" "MediaCover" "radarr.db" "config.xml"
}
SONARR_TAR_COMMAND() {
    tar -cf "$SONARR_TAR_FILE" "MediaCover" "sonarr.db" "config.xml"
}
LIDARR_TAR_COMMAND() {
    tar -cf "$LIDARR_TAR_FILE" "MediaCover" "lidarr.db" "config.xml"
}
PROWLARR_TAR_COMMAND() {
    tar -cf "$PROWLARR_TAR_FILE" "prowlarr.db" "config.xml"
}
#########################################################
################## END OF USER CONFIG ###################
##########################################################

echo_ts() { local ms=${EPOCHREALTIME#*.}; printf "[%(%Y_%m_%d)T %(%H:%M:%S)T.${ms:0:3}] $@\\n"; }

#function to find python binary
python_executable="$(command -v python3)"

if [[ -z $python_executable ]]; then
	echo_ts "Fail on python. Aborting."
  echo_ts "Install python 3 via your"
  echo_ts "favorite package manager."
	exit 1
fi
# function to verify path variables, this will eventually get better if I can figure out how.
verify_valid_path_variables() {
  if [ ! -d "$BACKUP_DIR" ]; then
      echo "Directory $BACKUP_DIR does not exist."
      exit 1
  fi
if [[ $RADARR_ENABLED = true ]]; then
    if [ ! -d "$RADARR_DIR" ]; then
        echo "Directory $RADARR_DIR does not exist."
        exit 1
    fi
fi
if [[ $SONARR_ENABLED = true ]]; then
    if [ ! -d "$SONARR_DIR" ]; then
        echo "Directory $SONARR_DIR does not exist."
        exit 1
    fi
fi
if [[ $LIDARR_ENABLED = true ]]; then
    if [ ! -d "$LIDARR_DIR" ]; then
        echo "Directory $LIDARR_DIR does not exist."
        exit 1
    fi
fi
if [[ $PROWLARR_ENABLED = true ]]; then
    if [ ! -d "$PROWLARR_DIR" ]; then
        echo "Directory $PROWLARR_DIR does not exist."
        exit 1
    fi
fi
}
# Function to back up the files.
backup_files() {
    echo_ts "Copying Files..."
    BACKUP_COMMAND
    echo_ts "Files copied."
}

# Function to set permissions on the backup sub-directory.
set_permissions() {
    echo_ts "Running 'chmod -R $PERMISSIONS' on backup sub-directory..."
    chmod -R $PERMISSIONS "$BACKUP_PATH"
    echo_ts "Successfully set permissions on backup sub-directory."
}

# Function to calculate the age of a tar file in seconds.
get_tarfile_age() {
    local tarfile="$1"
    local current_time=$(date +%s)
    local tarfile_creation_time=$(stat -c %Y "$tarfile")
    local age=$((current_time - tarfile_creation_time))
    echo "$age"
}

# Function to delete old backup tar files.
delete_old_backups() {
    local cutoff_age=$(($HOURS_TO_KEEP_BACKUPS_FOR * 3600))
    for tarfile in "$BACKUP_DIR"/*"$TARFILE_TEXT"*; do
        if [ -f "$tarfile" ]; then
            local tarfile_age=$(get_tarfile_age "$tarfile")
            if [ "$tarfile_age" -gt "$cutoff_age" ]; then
                rm -rf "$tarfile"
                echo_ts "Deleted old backup: $tarfile"
            fi
        fi
    done
}

# Function to create the Radarr tar file.
create_radarr_tar_file() {
    # Navigate to $RADARR_DIR working direcotry.
    cd "$RADARR_DIR"
    # Create sub-directory name with the custom timestamp.
    RADARR_TAR_FILE="$BACKUP_DIR/$(COMPLETE_RADARR_TARFILE_NAME)"
    echo_ts "Creating Radarr tar file..."
    # Run the tar command.
    RADARR_TAR_COMMAND
    echo_ts "Radarr Tar file created."
}
# Function to create the Sonarr  tar file.
create_sonarr_tar_file() {
    # Navigate to $SONARR_DIR working direcotry.
    cd "$SONARR_DIR"
    # Create sub-directory name with the custom timestamp.
    SONARR_TAR_FILE="$BACKUP_DIR/$(COMPLETE_SONARR_TARFILE_NAME)"
    echo_ts "Creating Sonarr tar file..."
    # Run the tar command.
    SONARR_TAR_COMMAND
    echo_ts "Sonarr Tar file created."
}
# Function to create the Sonarr tar file.
create_lidarr_tar_file() {
    # Navigate to $SONARR_DIR working direcotry.
    cd "$LIDARR_DIR"
    # Create sub-directory name with the custom timestamp.
    LIDARR_TAR_FILE="$BACKUP_DIR/$(COMPLETE_LIDARR_TARFILE_NAME)"
    echo_ts "Creating lidarr tar file..."
    # Run the tar command.
    LIDARR_TAR_COMMAND
    echo_ts "Lidarr Tar file created."
}
#function to create Prowlarr tar file.
create_prowlarr_tar_file() {
    # Navigate to $RADARR_DIR working direcotry.
    cd "$PROWLARR_DIR"
    # Create sub-directory name with the custom timestamp.
    PROWLARR_TAR_FILE="$BACKUP_DIR/$(COMPLETE_PROWLARR_TARFILE_NAME)"
    echo_ts "Creating Prowlarr tar file..."
    # Run the tar command.
    PROWLARR_TAR_COMMAND
    echo_ts "Prowlarr Tar file created."
}

set_permissions() {
    echo_ts "Running 'chmod $PERMISSIONS' on tar files..."
    if [[ $RADARR_ENABLED = true ]]; then chmod $PERMISSIONS "$RADARR_TAR_FILE"; fi
    if [[ $SONARR_ENABLED = true ]]; then chmod $PERMISSIONS "$SONARR_TAR_FILE"; fi
    if [[ $LIDARR_ENABLED = true ]]; then chmod $PERMISSIONS "$LIDARR_TAR_FILE"; fi
    if [[ $PROWLARR_ENABLED = true ]]; then chmod $PERMISSIONS "$PROWLARR_TAR_FILE"; fi
    echo_ts "Successfully set permissions on tar files."
}
#function to check and send webhook
send_notifiarr_webhook() {
    if [ $USE_NOTIFIARR = true ]; then
        echo_ts "[SENDING NOTIFICATION]"
        python3 "$(dirname "$BASH_SOURCE")"/../misc/notifiarr.py -e "Starr DB Backup" -c 1164585523348783104 -m "FFA500" -t "Backup Success" -g "[{$radarr_notification}, {$sonarr_notification}, {$lidarr_notification}]" -b "Backup was created at '$BACKUP_DIR'" -a "$ICON" -z "MYHM.Space"
    fi
}


###############################################
############# BACKUP BEGINS HERE ##############
###############################################


# Verify that $BACKUP_DIR and $PLEX_DIR are valid paths.
verify_valid_path_variables

# Delete old backup tar files first to create more usable storage space.
if [[ $HOURS_TO_KEEP_BACKUPS_FOR =~ ^[0-9]+(\.[0-9]+)?$ ]]; then delete_old_backups; fi

# Start backup message.
echo_ts "[STARR TARBALL BACKUP STARTED]"

# Create the tar files.
if [[ $RADARR_ENABLED = true ]]; then create_radarr_tar_file; fi
if [[ $SONARR_ENABLED = true ]]; then create_sonarr_tar_file; fi
if [[ $LIDARR_ENABLED = true ]]; then create_lidarr_tar_file; fi
if [[ $PROWLARR_ENABLED = true ]]; then create_prowlarr_tar_file; fi
# Set permissions for the tar files.
if [[ $PERMISSIONS =~ ^[0-9]{3,4}$ ]]; then set_permissions; fi

# Get size of current backup for notification.
if [[ $RADARR_ENABLED = true ]]; then radarr_notification="\"Radarr Backup Size\": \"$(ls -lh "$RADARR_TAR_FILE" | awk '{ print $5 }')\""; else radarr_notification=""; fi
if [[ $SONARR_ENABLED = true ]]; then sonarr_notification="\"Sonarr Backup Size\": \"$(ls -lh "$SONARR_TAR_FILE" | awk '{ print $5 }')\""; else sonarr_notification=""; fi
if [[ $LIDARR_ENABLED = true ]]; then lidarr_notification="\"Lidarr Backup Size\": \"$(ls -lh "$LIDARR_TAR_FILE" | awk '{ print $5 }')\""; else lidarr_notification=""; fi
if [[ $PROWLARR_ENABLED = true ]]; then prowlarr_notification="\"Prowlarr Backup Size\": \"$(ls -lh "$PROWLARR_TAR_FILE" | awk '{ print $5 }')\""; else prowlarr_notification=""; fi
# Backup completed message.
if [[ $RADARR_ENABLED = true ]]; then echo_ts "[RADARR TARBALL BACKUP COMPLETE] Backup created at '$RADARR_TAR_FILE'."; fi
if [[ $SONARR_ENABLED = true ]]; then echo_ts "[SONARR TARBALL BACKUP COMPLETE] Backup created at '$SONARR_TAR_FILE'."; fi
if [[ $LIDARR_ENABLED = true ]]; then echo_ts "[LIDARR TARBALL BACKUP COMPLETE] Backup created at '$LIDARR_TAR_FILE'."; fi
if [[ $PROWLARR_ENABLED = true ]]; then echo_ts "[PROWLARR TARBALL BACKUP COMPLETE] Backup created at '$PROWLARR_TAR_FILE'."; fi
# Send backup completed notification.

cd $WORKING_DIR
send_notifiarr_webhook


# Exit with success.
exit 0
