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
TS3LATEST=`curl --silent https://teamspeak.com/de/downloads/ | grep input | grep -o "http[^ ]*" | grep server | head -n 1 | sed -nre 's/^[^0-9]*(([0-9]+\.)*[0-9]+).*/\1/p'`

# prevent non-version given
if [ -z "$TS3LATEST" ]; then
TS3LATEST="0"
fi

# get local Version
TS3LOCAL=`ls -1rv $HOMEDIR | sed 's/ts3server*//g' | head -n 1`


if dpkg --compare-versions $TS3LATEST gt $TS3LOCAL ; then
        echo "TS3: newer Version ($TS3LATEST) found, downloading..."
        wget –q --no-cache --https-only -A "tar.bz2" –O "$HOMEDIR/$TS3FILE-$TS3LATEST.tar.bz2" "$TS3FILESERVER$TS3LATEST/$TS3FILE-$TS3LATEST.tar.bz2" &> /dev/null
        if [ -f "$HOMEDIR/$TS3FILE-$TS3LATEST.tar.bz2" ]; then
                echo "extracting..."
                tar -xf "$HOMEDIR/$TS3FILE-$TS3LATEST.tar.bz2"
                rm "$HOMEDIR/$TS3FILE-$TS3LATEST.tar.bz2"
                echo "prepare update..."
                mv "$TS3FILE" "ts3server$TS3LATEST"
                TARGET=`ls -1rv $HOMEDIR | grep ts3server | head -n 1`
                echo "updating symlinks..."
                ln -sfn $HOMEDIR/$TARGET $HOMEDIR/ts3server
                ln -s $HOMEDIR/server.ini $HOMEDIR/ts3server/ts3server.ini
                if [ -f "$HOMEDIR/licensekey.dat" ]; then
                        ln -s $HOMEDIR/licensekey.dat $HOMEDIR/ts3server/licensekey.dat
                fi
                ln -sfn $HOMEDIR/ts3files $HOMEDIR/ts3server/files
                ln -s $HOMEDIR/ts3server/redist/libmariadb.so.2 $HOMEDIR/ts3server/libmariadb.so.2
                echo "initiate server restart..."
                $TS3LOCAL/ts3server/ts3server_startscript.sh stop
        fi
fi
