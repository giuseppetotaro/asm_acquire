#!/usr/bin/env bash
#
# Script     : service.sh
# Usage      : ./asla.sh /path/tp/target /path/to/destination
# Author     : Giuseppe Totaro
# Date       : 2024-05-28
# Last Edited: 2024-05-28
# Description: ...
#              This script is released under the MIT License (MIT).
# Notes      : TCP and UDP ports used by Apple software products:
#              https://support.apple.com/en-us/103229
#

#set -o errexit
#set -o pipefail
#set -o nounset

# Global Variables

VERSION="1.0"
REPO="https://github.com/giuseppetotaro/asla"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SCRIPT_NAME="asla.sh"
SCRIPT_PATH="${SCRIPT_DIR}/../${SCRIPT_NAME}"  # Change it according to the 
                                               # actual location of asla.sh
SCREEN_SESSION="asla_session"

# Functions

#######################################
# Start asla.sh within a screen session.
# Globals:
#   SCREEN_SESSION
#   SCRIPT_NAME
#   SCRIPT_PATH
# Arguments:
#   computer_name, the name of the computer to be acquired. 
#   target, path to the target the mount point of the Mac's shared disk.
#   dest, path to the folder where the sparse image will be created. 
# Outputs:
#   Writes whether the process has started.
#######################################
process_start() {
  local computer_name="${1}"
  local target="${2}"
  local dest="${3}"
  if screen -list | grep "${SCREEN_SESSION}" >/dev/null
  then
    printf "# %s is already running.\n" "${SCRIPT_NAME}"
  else
    cmd="screen -S ${SCREEN_SESSION} -d -m bash -c '${SCRIPT_PATH} -a -n \"${computer_name}\" -u Guest --no-password \"${target}\" \"${dest}\"'"
    eval $cmd
    printf "# %s started in %s.\n" "${SCRIPT_NAME}" "${SCREEN_SESSION}"
  fi
}

#######################################
# Print help message.
# Arguments:
#   None
# Outputs:
#   Writes the help message to stdout.
#######################################
print_usage() {
cat << EOF
ASLA (Apple Silicon Logical Acquisition)  version $VERSION
Copyright (c) 2024 Giuseppe Totaro
GitHub repo: $REPO

asla.sh is provided "as is", WITHOUT WARRANTY OF ANY KIND. You are welcome to 
redistribute it under certain conditions. See the MIT Licence for details.

This script (service.sh) is intented to run asla.sh as a service.
asla.sh is a bash script to perform the logical acquisition of data from the 
targeted Apple Silicon Mac started in "share disk mode".

Usage:  ${0} start | stop | status

EOF
}

#######################################
# Backup the existing sparse image and log files to a specific folder named as
# the current date and time.
# Globals:
#   OUT_FILE
#   LOG_FILE
#   ERR_FILE
# Arguments:
#   destination path, the folder where the backup will be created.
#   image_name, the name of the sparse image without extension.
# Outputs:
#   Writes the backup folder and files to stdout.
#######################################
process_stop() { 
  if screen -list | grep "${SCREEN_SESSION}" >/dev/null
  then
    pkill -INT "SCREEN"  #TODO: Determine the PID in a more accurate way!
    screen -S "${SCREEN_SESSION}" -X quit
    printf "# %s stopped.\n" "${SCRIPT_NAME}"
  else
    printf "# %s is not running.\n" "${SCRIPT_NAME}"
  fi
}

#######################################
# Normalize a string by replacing spaces with %20.
# Arguments:
#   name, the string to be normalized.
#######################################
process_status() {
  if screen -list | grep "${SCREEN_SESSION}" >/dev/null
  then
    printf "# %s is running in screen session %s.\n" "${SCRIPT_NAME}" "${SCREEN_SESSION}"
  else
    printf "# %s is not running.\n" "${SCRIPT_NAME}"
  fi
}

#######################################
# Main function.
#######################################
main() {
  local computer_name=
  local target=
  local dest=

  case "${1}" in
    -h|--help)
      print_usage
      exit 0
      ;;
    start)
      #computer_name="${2}"
      #target="${3}"
      #dest="${4}"
      computer_name="$(python3 ${SCRIPT_DIR}/name.py)"
      target="/tmp/target"
      dest="/tmp/dest"
      process_start "${computer_name}" "${target}" "${dest}"
      ;;
    stop)
      process_stop
      ;;
    status)
      process_status
      ;;
    *)
      printf "Unknown argument passed: %s\n\n" "${1}" >&2
      print_usage >&2
      exit 1
      ;;
  esac
}

main "${@:-}"
