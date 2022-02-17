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

NAME=$1
DIR="$BASE_DIR/target/$NAME"
cat > $DIR/config.json <<EOF
{
  "platform": "linux64",
  "jdk": "$DIR/jdk$ID-lite",
  "executable": "example",
  "classpath": [
    "$BASE_DIR/lib/example.jar"
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
java -jar $BASE_DIR/lib/packr-legacy.jar $DIR/config.json

}

minify_macos_jre(){

NAME=$1
DIR="$BASE_DIR/target/$NAME"
cat > $DIR/config.json <<EOF
{
  "platform": "mac",
  "jdk": "$DIR/jdk$ID-lite.jdk",
  "executable": "example",
  "classpath": [
    "$BASE_DIR/lib/example.jar"
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
java -jar $BASE_DIR/lib/packr-legacy.jar $DIR/config.json

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
    "$BASE_DIR/lib/example.jar"
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
java -jar $BASE_DIR/lib/packr-legacy.jar $DIR/config.json

}

for PKG in $PKGS; do
    PKG_FILE="$PKG_PREFIX$PKG"
    NAME=${PKG%%.*}
    [ -e "$PKG_FILE" ] || curl -LO "$URL_PREFIX$PKG_FILE"
    case "$PKG" in
        windows*)
        [ ! -e "$NAME/jdk$ID-lite/jre" ] && \
            mkdir -p $NAME && cd $NAME && \
            unzip ../$PKG_FILE && cd - > /dev/null
        [ ! -e "$NAME/jdk$ID-tiny" ] && minify_windows_jre $NAME
        ;;
        macos*)
        [ ! -e "$NAME/jdk$ID-lite.jdk/jre" ] && \
            mkdir -p $NAME && cd $NAME && \
            tar -xvzf ../$PKG_FILE && cd - > /dev/null
        [ ! -e "$NAME/jdk$ID-tiny" ] && minify_macos_jre $NAME
        ;;
        *)
        [ ! -e "$NAME/jdk$ID-lite/jre" ] && \
            mkdir -p $NAME && cd $NAME && \
            tar -xvzf ../$PKG_FILE && cd - > /dev/null
        [ ! -e "$NAME/jdk$ID-tiny" ] && minify_linux_jre $NAME
        ;;
    esac
done
