#!/bin/sh

set -e

cd target

ID='8u322'
VERSION="$ID+6"
URL_PREFIX="https://download.bell-sw.com/java/$VERSION/"
PKG_PREFIX="bellsoft-jdk$VERSION-"
PKGS='
linux-amd64-lite.tar.gz
linux-aarch64-lite.tar.gz
macos-amd64-lite.tar.gz
macos-aarch64-lite.tar.gz
windows-amd64-lite.zip
'

for PKG in $PKGS; do
    PKG_FILE="$PKG_PREFIX$PKG"
    NAME=${PKG%%.*}
    [ -e "$PKG_FILE" ] || curl -LO "$URL_PREFIX$PKG_FILE"
    case "$PKG" in
        windows*)
        [ ! -e "$NAME/jdk$ID-lite/jre" ] && \
        mkdir -p $NAME && cd $NAME && \
        unzip ../$PKG_FILE && cd - > /dev/null
        ;;
        macos*)
        [ ! -e "$NAME/jdk$ID-lite.jdk/jre" ] && \
        mkdir -p $NAME && cd $NAME && \
        tar -xvzf ../$PKG_FILE && cd - > /dev/null
        ;;
        *)
        [ ! -e "$NAME/jdk$ID-lite/jre" ] && \
        mkdir -p $NAME && cd $NAME && \
        tar -xvzf ../$PKG_FILE && cd - > /dev/null
        ;;
    esac
done
