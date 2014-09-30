#!/bin/bash
# Disable all openstack services on all nodes

for node in $(crowbar machines list) ; do
    if [ -z $(crowbar machines show $node roles | grep "\"crowbar\"") ]; then
        echo "Disabling OpenStack services on ${node}..."
        SSH_SCRIPT="rcchef-client stop
    if [ \"ls /etc/init.d/openstack-*\" != \"\" ]; then
        for i in /etc/init.d/openstack-*; do
            chkconfig -d \$(basename \$i) > /dev/null
            \$i stop
        done
    fi"
        
        ssh $node "$SSH_SCRIPT"
        #ssh "$node" 'initscript=`basename $i`; chkconfig -d $initscript; $i stopinitscript=`basename $i`; chkconfig -d $initscript; $i stop; done; fi'
        #ssh "$node" 'rcchef-client stop; if ls /etc/init.d/openstack-* &>/dev/null; then for i in /etc/init.d/openstack-*; do initscript=`basename $i`; chkconfig -d $initscript; $i stop; done; fi'
    fi
done
