#!/bin/sh

set -e

BASE_DIR=$PWD

mkdir -p dist target
cd target

ID=$1
[ -z "$ID" ] && ID='8.422'
VERSION="$ID.05.1"
URL_PREFIX="https://corretto.aws/downloads/resources/$VERSION/"
PKG_PREFIX="amazon-corretto-$VERSION-"
PKGS='
linux-x64.tar.gz
linux-aarch64.tar.gz
macosx-x64.tar.gz
macosx-aarch64.tar.gz
windows-x64-jdk.zip
'

minify_linux_jre(){

NAME=$1
REL_HOME=$2
DIR="$BASE_DIR/target/$NAME"
OUT_DIR="$DIR/jdk$ID-tiny"
cat > $DIR/config.json <<EOF
{
  "platform": "linux64",
  "jdk": "$DIR/$REL_HOME",
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
  "output": "$OUT_DIR"
}
EOF
java -jar $BASE_DIR/lib/packr-legacy.jar $DIR/config.json
cd $OUT_DIR
#rm -r jre/lib/ext
rm -r jre/bin
tar -cvzf $BASE_DIR/dist/jre-$NAME.tar.gz jre
cd - > /dev/null

}

minify_macos_jre(){

NAME=$1
REL_HOME=$2
DIR="$BASE_DIR/target/$NAME"
OUT_DIR="$DIR/jdk$ID-tiny"
cat > $DIR/config.json <<EOF
{
  "platform": "mac",
  "jdk": "$DIR/$REL_HOME",
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
  "output": "$OUT_DIR"
}
EOF
java -jar $BASE_DIR/lib/packr-legacy.jar $DIR/config.json
cd $OUT_DIR/Contents/Resources
#rm -r jre/lib/ext
rm -r jre/bin
tar -cvzf $BASE_DIR/dist/jre-$NAME.tar.gz jre
cd - > /dev/null

}

minify_windows_jre(){

NAME=$1
REL_HOME=$2
DIR="$BASE_DIR/target/$NAME"
OUT_DIR="$DIR/jdk$ID-tiny"
cat > $DIR/config.json <<EOF
{
  "platform": "windows64",
  "jdk": "$DIR/$REL_HOME",
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
  "output": "$OUT_DIR"
}
EOF
java -jar $BASE_DIR/lib/packr-legacy.jar $DIR/config.json
cd $OUT_DIR
#rm -r jre/lib/ext
zip -r $BASE_DIR/dist/jre-$NAME.zip jre
cd - > /dev/null

}

for PKG in $PKGS; do
    PKG_FILE="$PKG_PREFIX$PKG"
    NAME=${PKG%%.*}
    [ -e "$PKG_FILE" ] || curl -LO "$URL_PREFIX$PKG_FILE"
    case "$PKG" in
        windows*)
        REL_HOME="jdk1.8.0_${ID##*.}"
        [ ! -e "$NAME/$REL_HOME/jre" ] && \
        mkdir -p $NAME && cd $NAME && \
        unzip ../$PKG_FILE && cd - > /dev/null
        [ ! -e "$NAME/jdk$ID-tiny" ] && minify_windows_jre $NAME $REL_HOME
        ;;
        macos*)
        REL_HOME='amazon-corretto-8.jdk/Contents/Home'
        [ ! -e "$NAME/$REL_HOME/jre" ] && \
        mkdir -p $NAME && cd $NAME && \
        tar -xvzf ../$PKG_FILE && cd - > /dev/null
        [ ! -e "$NAME/jdk$ID-tiny" ] && minify_macos_jre $NAME $REL_HOME
        ;;
        *)
        REL_HOME="amazon-corretto-$VERSION-$NAME"
        [ ! -e "$NAME/$REL_HOME/jre" ] && \
        mkdir -p $NAME && cd $NAME && \
        tar -xvzf ../$PKG_FILE && cd - > /dev/null
        [ ! -e "$NAME/jdk$ID-tiny" ] && minify_linux_jre $NAME $REL_HOME
        ;;
    esac
done
