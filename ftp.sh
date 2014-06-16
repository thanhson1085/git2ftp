#!/bin/bash

# ------------------------------------------------------------
# Defaults
# ------------------------------------------------------------
REMOTE_PROTOCOL="ftp"
REMOTE_HOST="YOUR_HOST"
REMOTE_USER="USERNAME"
REMOTE_PASSWD="PASSWORD"
REMOTE_PATH=""
REMOTE_CMD_OPTIONS="-s"
SYNCROOT=""
CURL_DISABLE_EPSV=0
declare -a CURL_ARGS
declare -i ACTIVE_MODE=0

# ------------------------------------------------------------
# Constant Exit Error Codes
# ------------------------------------------------------------
readonly ERROR_UPLOAD=4

SRC_FILE="$1"
DEST_FILE="$2"

set_default_curl_options() {
	OIFS="$IFS"
	IFS=" "
	CURL_ARGS=(${REMOTE_CMD_OPTIONS[@]})
	IFS="$OIFS"
	CURL_ARGS+=(--globoff)
	if [ ! -z $REMOTE_USER ]; then
		CURL_ARGS+=(--user "$REMOTE_USER":"$REMOTE_PASSWD")
	else
		CURL_ARGS+=(--netrc)
	fi
	CURL_ARGS+=(-#)
	if [ $ACTIVE_MODE -eq 1 ]; then
		CURL_ARGS+=(-P "-")
	else
		if [ $CURL_DISABLE_EPSV -eq 1 ]; then
			CURL_ARGS+=(--disable-epsv)
		fi
	fi
}

check_exit_status() {
	if [ $? -ne 0 ]; then
		print_error_and_die "$1, exiting..." $2
	fi
}

print_error_and_die() {
	echo "fatal: $1"
}

if [ -z $DEST_FILE ]; then
	DEST_FILE=$SRC_FILE
fi

if [ -n "$SYNCROOT" ]; then
	DEST_FILE=${DEST_FILE/$SYNCROOT/$REPLACE}
fi

set_default_curl_options
CURL_ARGS+=(-T "$SRC_FILE")
CURL_ARGS+=(--ftp-create-dirs)
CURL_ARGS+=("$REMOTE_PROTOCOL://$REMOTE_HOST/${REMOTE_PATH}${DEST_FILE}")

# push file to FTP server via CURL
curl "${CURL_ARGS[@]}"
check_exit_status "Could not upload file: '${REMOTE_PATH}$DEST_FILE'." $ERROR_UPLOAD

