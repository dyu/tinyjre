#!/bin/sh

cd target

VERSION='8u322+6'
URL_PREFIX="https://download.bell-sw.com/java/$VERSION/"
PKGS="
bellsoft-jdk$VERSION-linux-amd64-lite.tar.gz
bellsoft-jdk$VERSION-linux-aarch64-lite.tar.gz
bellsoft-jdk$VERSION-macos-amd64-lite.tar.gz
bellsoft-jdk$VERSION-macos-aarch64-lite.tar.gz
bellsoft-jdk$VERSION-windows-amd64-lite.zip
"

for PKG in $PKGS; do
    #echo $PKG
    [ -e "$PKG" ] || curl -LO "$URL_PREFIX$PKG"
done
