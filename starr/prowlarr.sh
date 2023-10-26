#!/bin/bash

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
PROWLARR_TARFILE_TEXT="Prowlarr-Backup"
TIMESTAMP() { date +"%Y_%m_%d"; }
COMPLETE_PROWLARR_TARFILE_NAME() { echo "[$(TIMESTAMP)] $PROWLARR_TARFILE_TEXT.tar"; }
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
# function to verify path variables.
verify_valid_path_variables() {
    local dir_vars=("BACKUP_DIR" "PROWLARR_DIR")
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



# Function to create the prowlarr tar file.
create_prowlarr_tar_file() {
    # Navigate to $PROWLARR_DIR working direcotry.
    cd "$PROWLARR_DIR"
    # Create sub-directory name with the custom timestamp.
    PROWLARR_TAR_FILE="$BACKUP_DIR/$(COMPLETE_PROWLARR_TARFILE_NAME)"
    echo_ts "Creating prowlarr tar file..."
    # Run the tar command.
    PROWLARR_TAR_COMMAND
    echo_ts "Prowlarr Tar file created."
}

set_permissions() {
    echo_ts "Running 'chmod $PERMISSIONS' on tar files..."
    if [[ $PROWLARR_ENABLED = true ]]; then chmod $PERMISSIONS "$PROWLARR_TAR_FILE"; fi
    echo_ts "Successfully set permissions on tar files."
}



###############################################
############# BACKUP BEGINS HERE ##############
###############################################


# Verify that $BACKUP_DIR and $PROWLARR_DIR are valid paths.
verify_valid_path_variables

# Delete old backup tar files first to create more usable storage space.
if [[ $HOURS_TO_KEEP_BACKUPS_FOR =~ ^[0-9]+(\.[0-9]+)?$ ]]; then delete_old_backups; fi

# Start backup message.
echo_ts "[PROWLARR TARBALL BACKUP STARTED]"
# Create the tar files.
if [[ $PROWLARR_ENABLED = true ]]; then create_prowlarr_tar_file; fi
# Set permissions for the tar files.
if [[ $PERMISSIONS =~ ^[0-9]{3,4}$ ]]; then set_permissions; fi

# Backup completed message.

current_backup_size=$(ls -lh "$PROWLARR_TAR_FILE" | awk '{ print $5 }')


# Exit with success.
cd $WORKING_DIR
