#!/bin/bash
hugo
Rss2Outbox --rssPath public/index.xml \
    --staticPath static \
    --authorUsername "\@mapache@hachyderm.io" \
    --siteActorUri "https://maho.dev/@blog" \
    --domain "https://maho.dev"
hugo