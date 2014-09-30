#!/bin/bash
# Shutdown all instances in a cloud
#
# exit status 1: the ~/.openrc file is missing
# another exit stauts: something else went wrong

EXIT=0
FILEDIR=$(dirname ${BASH_SOURCE[0]})

if [ ! -f /opt/dell/crowbar_framework/.crowbar-installed-ok ]; then
    echo "please run this script on the crowbar node."
    exit 1
fi

for node in $(crowbar machines list); do
    if [ ! -z $(crowbar machines show $node roles | grep nova-multi-controller) ]; then
        SSH_SCRIPT="TMP_FILE=\"shutdown_instances_script.tmp\"
INSTANCES=0
INSTANCES_STOPPED=0
EXIT=0

if [ -f ~/.openrc ]; then
  . ~/.openrc
else
    echo \"the ~/.openrc file is not available on node $node\"
    exit 1
fi

for tenant_id in \$(keystone tenant-list | grep -v ' service ' | tail -n +4 | head -n -1 | cut -d'|' -f2); do
    for server_id in \$(nova --os-tenant-id \"\$tenant_id\" list | grep -v PAUSED | tail -n +4 | head -n -1 | cut -d'|' -f2); do
        let \"INSTANCES++\"
        ERRORMSG=\"\"
        nova --os-tenant-id \$tenant_id pause \$server_id &> /tmp/\$TMP_FILE

        if [[ \$? == \"0\" ]]; then
            STATUS=\"$(tput setaf 2)done$(tput sgr0)\"
            let \"INSTANCES_STOPPED++\"
        else
            STATUS=\"$(tput setaf 1)error$(tput sgr0)\"
            let \"INSTANCES++\"

            if [ \"\$(cat /tmp/\$TMP_FILE | grep \"ERROR: Cannot 'pause' while instance is in vm_state stopped\")\" ]; then
                ERRORMSG=\" (vm is already stopped)\"
            else
                EXIT=2
            fi
        fi

        echo \"[\$STATUS] Pausing server id \$server_id on tenant \$tenant_id\$ERRORMSG\"
        
        if [ \"\$EXIT\" != \"0\" ]; then
            exit \$EXIT
        fi
    done
done

if [ \$INSTANCES == \"0\" ]; then
    echo \"Could not pause any machine, because no machines are set up or are have the \"PAUSE\" status.\"
else
    echo \"Paused \$INSTANCES_STOPPED of \$INSTANCES instances.\"
fi

if [ -f /tmp/\$TMP_FILE ]; then
    rm /tmp/\$TMP_FILE
fi"
        ssh $node "$SSH_SCRIPT"
    fi
done
