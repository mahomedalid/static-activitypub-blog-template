#!/bin/bash
VERSION="0.0.3"
wget https://github.com/mahomedalid/almost-static-activitypub/releases/download/$VERSION/activitypub-utils-$VERSION-linux-x64.tar.gz
mkdir -p ~/.activitypubdotnet
tar -xzvf activitypub-utils-$VERSION-linux-x64.tar.gz  -C ~/.activitypubdotnet/
ln -s ~/.activitypubdotnet/activitypub-utils-$VERSION-linux-x64/ ~/.activitypubdotnet/latest
export PATH=$PATH:~/.activitypubdotnet/latest