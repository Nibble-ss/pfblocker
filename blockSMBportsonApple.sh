#!/bin/bash
# ***************************************************************************
# Notes: 

# This is a script that will block SMB ports (139, 445) in the pf firewall on OS X. 
# By blocking SMB ports, OS X will be forced to use AFP (548).
# This script has been tested on the following OS X builds:
# - 10.13.x - macOS High Sierra 

# ***************************************************************************
# Script Syntax
# Feed the server IP into the command like so

# 	./script.sh [server IP]
# ***************************************************************************


SERVER=$1
ANCHOR_DIRECTORY=/private/etc/pf.anchors/
PF_CONF_DIRECTORY=/etc/pf.conf
ANCHOR_NAME=org.user.block.outbound.smb

if [ -d $ANCHOR_DIRECTORY ] && [ ! -f $ANCHOR_NAME ]; then
	touch $ANCHOR_DIRECTORY/$ANCHOR_NAME
	echo "blocksmbhosts = \"{ $SERVER }\"" >> $ANCHOR_DIRECTORY/$ANCHOR_NAME 
	echo 'blocksmbports = "{ 139, 445 }"' >> $ANCHOR_DIRECTORY/$ANCHOR_NAME
	echo 'block drop out proto tcp to $blocksmbhosts port $blocksmbports' >> $ANCHOR_DIRECTORY/$ANCHOR_NAME
fi

if [ $PF_CONF_DIRECTORY ]; then
	echo "load anchor \"$ANCHOR_NAME\" from \"/etc/pf.anchors/$ANCHOR_NAME\"" >> /etc/pf.conf
fi

pfctl -vf /etc/pf.anchors/$ANCHOR_NAME >/dev/null 2>&1
pfctl -e >/dev/null 2>/dev/null

echo "Firewall rules updated"
echo ""
read -p "Press any key to continue... `echo $'\n'`" -n1 -s
