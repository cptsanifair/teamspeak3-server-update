#!/usr/bin/env bash
#
# TeamSpeak3 Update Script
#

# get home folder
TMP_LIST_PASSWD=( $(getent passwd `/usr/bin/id -un` | sed 's/:/ /g' ))
HOMEDIR=${TMP_LIST_PASSWD[5]}
unset TMP_LIST_PASSWD

# FILESERVER
TS3FILESERVER="https://files.teamspeak-services.com/releases/server/"
# needed file (Server Plattform Version)
TS3FILE="teamspeak3-server_linux_amd64"

# get latest Version
TS3LATEST=`curl $TS3FILESERVER --silent | sed -e 's/<[^>]*.//g' | grep '^[0-9]' | sort -r -V | head -n 1`
TS3LATEST=${TS3LATEST//[^0-9.]/}

# get local Version
TS3LOCAL=`ls -1rv $HOMEDIR | sed 's/ts3server*//g' | head -n 1`


if dpkg --compare-versions $TS3LATEST gt $TS3LOCAL ; then
        echo "newer Version ($TS3LATEST) found, downloading..."
        wget –q --no-cache --https-only -A "tar.bz2" –O "$HOMEDIR/$TS3FILE-$TS3LATEST.tar.bz2" "$TS3FILESERVER$TS3LATEST/$TS3FILE-$TS3LATEST.tar.bz2" &> /dev/null
        if [ -f "$HOMEDIR/$TS3FILE-$TS3LATEST.tar.bz2" ]; then
                echo "extracting..."
                tar -xf "$HOMEDIR/$TS3FILE-$TS3LATEST.tar.bz2"
                rm "$HOMEDIR/$TS3FILE-$TS3LATEST.tar.bz2"
                echo "prepare update..."
                mv "$TS3FILE" "ts3server$TS3LATEST"
                TARGET=`ls -1rv $HOMEDIR | grep ts3server | head -n 1`
                echo "updateing folder..."
                ln -sfn $HOMEDIR/$TARGET $HOMEDIR/ts3server && \
                ln -s $HOMEDIR/server.ini $HOMEDIR/ts3server/ts3server.ini || echo "somthing failed"
                ln -s $HOMEDIR/ts3server/redist/libmariadb.so.2 $HOMEDIR/ts3server/libmariadb.so.2
                echo "initiate server restart..."
                $HOMEDIR/ts3server/ts3server_startscript.sh stop
        fi
fi

