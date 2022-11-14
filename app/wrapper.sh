#!/bin/bash

# Multi-line:
# docker run -d \
# -v /appdata/test/config:/config \
# -v /appdata/test/downloads \
# -e SLEEP_INTERVAL=60
# -p 7634:7634 \
# --name test \
# overbyrn/docker/test
#
# One-liner (interactive, destroy container upon exit)
# docker run --rm -it -v /appdata/test/config:/config -v /appdata/test/downloads:/downloads -e SLEEP_INTERVAL=60 -p 7634:7634 --name test overbyrn/docker-test
#
# Example:
# docker run --rm -it -v /appdata/test/config:/config -v /appdata/test/downloads:/downloads -e BDFR_WAIT=60 -e BDFR_VERBOSE=2 -p 7634:7634 --name test overbyrn/docker-test
#


#Debug
[[ $DEBUG ]] && set -x

# INIT VARS - BDFR specific. Values here will override those set in options.yaml
#
BDFR_POSTLIMIT="${BDFR_POSTLIMIT:-}"		# default limit of number of submissions retrieve
BDFR_WAIT="${BDFR_WAIT:-60}"				# default wait time between bdfr runs. unit: seconds
BDFR_AUTH="${BDFR_AUTH:-false}"				# default run without an authenticated reddit session
BDFR_USER="${BDFR_USER:-}"					# the user to scrape as when running an authenticated session
BDFR_VERBOSE=${BDFR_VERBOSE:-}				# NULL or 0=INFO, 1=DEBUG, 2=FULL. increase the verbosity of the program
BDFR_NODUPES="${BDFR_NODUPES:-true}"		# will not redownload files if they already exist somewhere in the download folder tree
BDFR_SORT="${BDFR_SORT:-}"					# sort type. options: controversial, hot, new, relevance (only available when using --search), rising, top
#
# INIT VARS - Other
#
BDFR_DETOX="${BDFR_DETOX:-false}"			# True/False - whether to run detox to clean-up filenames
BDFR_RDFIND="${BDFR_RDFIND:-false}"			# True/False - whether to run rdfind to replace duplicate files
BDFR_RDFIND_OPTS="${BDFR_RDFIND_OPTS:-}"	# Use these options when running rdfind. Default action: convert duplicates to symlinks
BDFR_SYMLINKS="${BDFR_SYMLINKS:-false}"		# True/False - whether to run symlinks to change absolute/messy links to relative


function log() {
  local time=$(date +"%F %T")
  echo "$time $1 "
  echo "[$time] $1 " &>> /app/start.log
}

function countdown() {
  # $1 = # of seconds
  # $@ = What to print after "Waiting n seconds"
  secs=$1
  shift
  msg=$@
  while [ $secs -gt 0 ]
  do
    printf "\r\033[KWaiting %.d seconds $msg" $((secs--))
    sleep 1
  done
  echo
}

# Stage default configuration files to config dir if required
if [ ! -f "/config/options.yaml" ]; then 
  log "options.yaml not found, using default"
  cp /app/options.yaml.example /config/options.yaml
fi
if [ ! -f "/config/config.cfg" ]; then 
  log "config.cfg not found, using default"
  cp /app/default_config.cfg /config/config.cfg
fi

# Build command opts
_OPTS="--config /config/config.cfg --opts /config/options.yaml"
if [ ! -z ${BDFR_POSTLIMIT} ]; then
  _OPTS="${_OPTS} --limit ${BDFR_POSTLIMIT}"
fi
if [ ${BDFR_AUTH,,} == "true" ]; then
  _OPTS="${_OPTS} --authenticate"
fi
if [ ! -z ${BDFR_USER} ]; then
  _OPTS="${_OPTS} --user ${BDFR_USER}"
fi
if [ ${BDFR_VERBOSE} -gt 0 ]; then
  if [ ${BDFR_VERBOSE} -eq 1 ]; then
    _OPTS="${_OPTS} --verbose"
  else
    _OPTS="${_OPTS} --verbose --verbose"
  fi
fi
if [ ${BDFR_NODUPES,,} == "true" ]; then
  _OPTS="${_OPTS} --no-dupes"
fi

# Run BDFR
log "Running BDFR"
python -m bdfr download /downloads $_OPTS
log "BDFR run complete"

# Run detox
if [ "${BDFR_DETOX,,}" = "true" ]; then
  log "Running detox"
  detox -r -v /downloads
  log "detox done"
fi

# Run rdfind
if [ "${BDFR_RDFIND,,}" = "true" ]; then
  log "Running rdfind"
  if [ -z "${BDFR_RDFIND_OPTS}" ]; then	# run rdfind with default settings, convert dupes to symlinks
    rdfind -makeresultsfile false -makesymlinks true /downloads
  else
    rdfind "${BDFR_RDFIND_OPTS}" /downloads
    log "rdfind done"
  fi
fi

# Run symlinks
if [ "${BDFR_SYMLINKS,,}" = "true" ]; then
  log "Running symlinks; change absolute/messy links to relative"
  symlinks -corv /downloads
  log "symlinks done"
fi

log "Waiting for ${BDFR_WAIT} seconds"
! $DEBUG && countdown ${BDFR_WAIT} "until next run" || sleep ${BDFR_WAIT}s