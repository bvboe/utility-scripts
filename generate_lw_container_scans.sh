#!/bin/bash
# Script to scan a Docker v2 compatible registry, extract a list of images 
# and generate script to scan those images using the Lacework CLI
#
# Usage: generate_lw_container_scans.sh <registry> <username> <password>
#

if [ $# -ne 3 ]
  then
    echo "Usage: generate_lw_container_scans.sh <registry> <username> <password>"
    exit 1
fi


registry=$1
credentials=$2:$3

catalog=`curl -s -u "$credentials" https://$registry/v2/_catalog | jq 'flatten' | jq -r -c '.[]'`

for item in $catalog;
do
  url=https://$registry/v2/$item/tags/list
  taglist=`curl -s -u "$credentials" $url`
  tags=`echo $taglist | jq -r '.tags' | jq -r -c '.[]'`

  for tag in $tags
  do
    #echo $registry/$item:$tag
    echo lacework vulnerability container scan $registry $item $tag
  done
done
