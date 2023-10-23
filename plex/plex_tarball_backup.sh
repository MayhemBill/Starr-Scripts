#!/bin/bash

# This script is designed to backup only the essential files that *DO NOT* require the Plex server to be shut down.
# By default, this script will backup the "Media" and "Metadata" folders of Plex to a tar file with a timestamp of the current time.
# You can edit the tar command used in the config below. (ie. specify different folders/files to backup, use compression, etc.)

#Load .env before anything else
if [ -f "$(dirname "$BASH_SOURCE")"/../.env ]
then
  export $(cat "$(dirname "$BASH_SOURCE")"/../.env | sed 's/#.*//g' | xargs)
fi
#########################################################
################### USER CONFIG BELOW ###################
#########################################################

HOURS_TO_KEEP_BACKUPS_FOR="324"  # Delete backups older than this many hours. Comment out or delete to disable.
STOP_PLEX_DOCKER=false  # Shutdown Plex docker before backup and restart it after backup. Set to "true" (without quotes) to use. Comment out or delete to disable.
PERMISSIONS="777"  # Set to any 3 or 4 digit value to have chmod set those permissions on the final tar file. Comment out or delete to disable.
#----------- OPTIONAL ADVANCED CONFIG BELOW ------------#
TARFILE_TEXT="Plex-Metadata-Backup"  # OPTIONALLY customize the text for the backup tar file. As a precaution, the script only deletes old backups that match this pattern.
TIMESTAMP() { date +"%Y_%m_%d"; }  # OPTIONALLY customize TIMESTAMP for the tar filename.
COMPLETE_TARFILE_NAME() { echo "[$(TIMESTAMP)] $TARFILE_TEXT.tar"; }  # OPTIONALLY customize the complete tar file name (adding extension) with the TIMESTAMP and TARFILE_TEXT.
TAR_COMMAND() {  # OPTIONALLY customize the TAR command. Use "$TAR_FILE" for the tar file name. This command is ran from within the $PLEX_DIR directory.
    tar -cf "$TAR_FILE" "Media" "Metadata"
}
ABORT_SCRIPT_RUN_IF_ACTIVE_PLEX_SESSIONS=false  # OPTIONALLY abort the script from running if there are active sessions on the Plex server.
PLEX_SERVER_URL_AND_PORT="$PLEX_URL"  # ONLY REQUIRED if using 'ABORT_SCRIPT_RUN_IF_ACTIVE_PLEX_SESSIONS' is set to 'true'.
PLEX_TOKEN="$PLEX_TOKEN"  # ONLY REQUIRED if using 'ABORT_SCRIPT_RUN_IF_ACTIVE_PLEX_SESSIONS' is set to 'true'.
INCLUDE_PAUSED_SESSIONS=false  # Include paused Plex sessions if 'ABORT_SCRIPT_RUN_IF_ACTIVE_PLEX_SESSIONS' is set to 'true'.
ALSO_ABORT_ON_FAILED_CONNECTION=false  # Also abort the script if the connection to the Plex server fails.

#########################################################
################## END OF USER CONFIG ###################
#########################################################

# Function to append timestamps on all script messages printed to the console.
echo_ts() { local ms=${EPOCHREALTIME#*.}; printf "[%(%Y_%m_%d)T %(%H:%M:%S)T.${ms:0:3}] $@\\n"; }

#function to find python binary
python_executable="$(command -v python3)"

if [[ -z $python_executable ]]; then
	echo_ts "Fail on python. Aborting."
  echo_ts "Install python 3 via your"
  echo_ts "favorite package manager."
	exit 1
fi

# Function to abort script if there are active users on the Plex server.
abort_script_run_due_to_active_plex_sessions() {
    response=$(curl -s --fail --connect-timeout 10 "${PLEX_SERVER_URL_AND_PORT}/status/sessions?X-Plex-Token=${PLEX_TOKEN}")
    if [[ $? -ne 0 ]] && [[ $ALSO_ABORT_ON_FAILED_CONNECTION = true ]]; then
        echo_ts "[ERROR] Could not connect to Plex server. Aborting Plex Metadata Backup."
        exit 1
    elif [[ $response == *'state="playing"'* ]] || ( [[ $INCLUDE_PAUSED_SESSIONS = true ]] && [[ $response == *'state="paused"'* ]] ); then
        echo_ts "Active users on Plex server. Aborting Plex Metadata Backup."
        exit 0
    fi
}

# Function to verify that "$BACKUP_DIR" and "$PLEX_DIR" are valid paths.
verify_valid_path_variables() {
    local dir_vars=("BACKUP_DIR" "PLEX_DIR")
    for dir in "${dir_vars[@]}"; do
        local clean_dir="${!dir}"
        clean_dir="${clean_dir%/}"  # Remove trailing slashes
        eval "$dir=\"$clean_dir\""  # Update the variable with the cleaned path
        if [ ! -d "$clean_dir" ]; then
            echo "[ERROR] Directory not found: $clean_dir"
            exit 1
        fi
    done
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

# Function to stop Plex docker.
stop_plex() {
    echo_ts "Stopping Plex Server..."
    docker stop "$PLEX_DOCKER_NAME" >/dev/null
    echo_ts "Plex Server stopped."
}

# Function to create the tar file.
create_tar_file() {
    # Navigate to $PLEX_DIR working direcotry.
    cd "$PLEX_DIR"
    # Create sub-directory name with the custom timestamp.
    TAR_FILE="$BACKUP_DIR/$(COMPLETE_TARFILE_NAME)"
    echo_ts "Creating tar file..."
    # Run the tar command.
    TAR_COMMAND
    echo_ts "Tar file created."
}

# Function to start Plex docker.
start_plex() {
    echo_ts "Starting Plex Server..."
    docker start "$PLEX_DOCKER_NAME" >/dev/null
    echo_ts "Plex Server started."
}

# Function to set permissions on the tar file.
set_permissions() {
    echo_ts "Running 'chmod $PERMISSIONS' on tar file..."
    chmod $PERMISSIONS "$TAR_FILE"
    echo_ts "Successfully set permissions on tar file."
}

# Function to send backup success to notifiarr
send_notifiarr_webhook() {
    if [ $USE_NOTIFIARR = true ]; then
        echo_ts "[SENDING NOTIFICATION]"
        python3 $WORKING_DIR/misc/notifiarr.py -e "Plex Data Backup" -c 1164585523348783104 -m "FFA500" -t "Data Backup Success" -g "[{\"Backup Size\": \"$current_backup_size\"}, {\"File\": \"$(COMPLETE_TARFILE_NAME)\"}]" -b "Backup was created at '$BACKUP_DIR'" -a "https://notifiarr.com/images/logo/plex.png" -z "MYHM.Space"
    fi
}
###############################################
############# BACKUP BEGINS HERE ##############
###############################################

# Abort script if there are active users on the Plex server.
if [[ $ABORT_SCRIPT_RUN_IF_ACTIVE_PLEX_SESSIONS = true ]]; then abort_script_run_due_to_active_plex_sessions; fi

# Verify that $BACKUP_DIR and $PLEX_DIR are valid paths.
verify_valid_path_variables

# Delete old backup tar files first to create more usable storage space.
if [[ $HOURS_TO_KEEP_BACKUPS_FOR =~ ^[0-9]+(\.[0-9]+)?$ ]]; then delete_old_backups; fi

# Start backup message.
echo_ts "[PLEX TARBALL BACKUP STARTED]"

# Stop Plex Docker.
if [[ $STOP_PLEX_DOCKER = true ]]; then stop_plex; fi

# Create the tar file.
create_tar_file

# Start Plex Docker before doing anything else.
if [[ $STOP_PLEX_DOCKER = true ]]; then start_plex; fi

# Set permissions for the tar file.
if [[ $PERMISSIONS =~ ^[0-9]{3,4}$ ]]; then set_permissions; fi

# Get size of current backup for notification.
current_backup_size=$(ls -lh "$TAR_FILE" | awk '{ print $5 }')

# Backup completed message.
echo_ts "[PLEX TARBALL BACKUP COMPLETE] Backed created at '$TAR_FILE'."

# Send backup completed notification.
send_notifiarr_webhook


# Exit with success.
exit 0
