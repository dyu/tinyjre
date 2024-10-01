#!/bin/sh

set -e

TARGETS='
jre-linux-x64.tar.gz
jre-linux-aarch64.tar.gz
jre-macosx-x64.tar.gz
jre-macosx-aarch64.tar.gz
jre-windows-x64.zip
'

for T in $TARGETS; do
    [ ! -e "dist/$T" ] && echo "dist/$T is missing." && exit 1
done

echo "$#"

[ "$#" -lt 2 ] && \
echo "1st arg(version) and 2nd arg(github auth token) are required." && \
exit 1

APP=tinyjre
DIST_DIR=dist
DIST_VERSION=$1
REPO_USER=dyu
REPO_NAME=tinyjre
AUTH_USER=dyu
AUTH_TOKEN=$2

cd $DIST_DIR

[ -z "$GITHUB_RELEASE" ] && GITHUB_RELEASE=github-release

upload_target(){
    UPLOAD_FILE=$1
    echo "### Uploading $UPLOAD_FILE"
    GITHUB_TOKEN=$AUTH_TOKEN GITHUB_AUTH_USER=$AUTH_USER $GITHUB_RELEASE upload \
        --user $REPO_USER \
        --repo $REPO_NAME \
        --tag v$DIST_VERSION \
        --name $UPLOAD_FILE \
        --file $UPLOAD_FILE
}

echo "# Tagging v$DIST_VERSION"
GITHUB_TOKEN=$AUTH_TOKEN GITHUB_AUTH_USER=$AUTH_USER $GITHUB_RELEASE release \
    --user $REPO_USER \
    --repo $REPO_NAME \
    --tag v$DIST_VERSION \
    --name "$APP-v$DIST_VERSION" \
    --description "tiny jre for linux/macos/windows"

for T in $TARGETS; do
    upload_target $T
done

echo v$DIST_VERSION released!
