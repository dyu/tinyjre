#!/bin/sh

set -e

BASE_DIR=$PWD

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

minify_linux_jre(){

#TODO
NAME=$1
DIR="$BASE_DIR/target/$NAME"
echo $DIR

}

minify_macos_jre(){

#TODO
NAME=$1
DIR="$BASE_DIR/target/$NAME"
echo $DIR

}

minify_windows_jre(){

NAME=$1
DIR="$BASE_DIR/target/$NAME"
cat > $DIR/config.json <<EOF
{
  "platform": "windows64",
  "jdk": "$DIR/jdk$ID-lite",
  "executable": "example",
  "classpath": [
    "target/example.jar"
  ],
  "mainclass": "example.Main",
  "vmargs": [
    "Xms256G",
    "Xmx256G"
  ],
  "minimizejre": "$BASE_DIR/tiny.json",
  "output": "$DIR/jdk$ID-tiny"
}
EOF

}

for PKG in $PKGS; do
    PKG_FILE="$PKG_PREFIX$PKG"
    NAME=${PKG%%.*}
    [ -e "$PKG_FILE" ] || curl -LO "$URL_PREFIX$PKG_FILE"
    case "$PKG" in
        windows*)
        if [ -e "$NAME/jdk$ID-lite/jre" ]; then
            minify_windows_jre $NAME
        else
            mkdir -p $NAME && cd $NAME && \
            unzip ../$PKG_FILE && \
            minify_windows_jre $NAME && cd - > /dev/null
        fi
        ;;
        macos*)
        if [ -e "$NAME/jdk$ID-lite.jdk/jre" ]; then
            minify_macos_jre $NAME
        else
            mkdir -p $NAME && cd $NAME && \
            tar -xvzf ../$PKG_FILE && \
            minify_macos_jre $NAME && cd - > /dev/null
        fi
        ;;
        *)
        if [ -e "$NAME/jdk$ID-lite/jre" ]; then
            minify_linux_jre $NAME
        else
            mkdir -p $NAME && cd $NAME && \
            tar -xvzf ../$PKG_FILE && \
            minify_linux_jre $NAME && cd - > /dev/null
        fi
        ;;
    esac
done
