#!/bin/bash
# this script shuts down an entire cloud
#
# exit status 0: everything was fine
# exit status 1: the script was not running on the crowbar node
# other exit status: something went wrong in a executed script

# get the directory where the file is stored
FILEDIR=$(dirname ${BASH_SOURCE[0]})
MAX_STEPS=4

# detect error
function detectError {
    if [[ $1 != "0" ]]; then
        echo "[Error] Script exited with exit code $1"
        exit $1
    fi
}

# check if the script is running on the crowbar node or not
if [ ! -f /opt/dell/crowbar_framework/.crowbar-installed-ok ]; then
    echo "please run this script on the crowbar node."
    exit 1
fi

# shutdown process
echo "-- Shutting down the entire cloud --"

# shutdown_instances.sh
echo "Stopping all virtual instances (1/$MAX_STEPS)"
$FILEDIR/shutdown_instances.sh
detectError $?

# shutdown_services.sh
echo "Shutting down all services (2/$MAX_STEPS)"
$FILEDIR/shutdown_services.sh
detectError $?

# shutdown_nodes.sh
echo "Shutting down all nodes (3/$MAX_STEPS)"
$FILEDIR/shutdown_nodes.sh
detectError $?

# shutdown_nodes.sh adminnode
echo "Shutting down the adminnode (4/$MAX_STEPS)"
$FILEDIR/shutdown_nodes.sh adminnode
detectError $?
