#!/bin/bash
hugo
Rss2Outbox --rssPath public/index.xml \
    --staticPath static \
    --authorUsername $1 \
    --siteActorUri $2 \
    --domain $3
hugo