#!/bin/bash

if [ ! -n "$1" ] || [ ! -n "$2" ]; then
    echo "Invalid parameters provided. Info: ./ghdownload.sh <org> <repo> [<output_file>]"
    exit -1
fi

org=$1
repo=$2
token=$GHDOWNLOAD_TOKEN
output_file=$4

url="https://api.github.com/repos/$org/$repo"
api_ver="X-GitHub-Api-Version: 2022-11-28"
auth="Authorization: Bearer $token"
accept_json="Accept: application/vnd.github+json"
accept_stream="Accept: application/octet-stream"

rel_id=$(curl -s -L -H "$accept_json" -H "$auth" -H "$api_ver" $url/releases/latest | jq -r '.id')
echo "Release Id: $rel_id"

asset=$(curl -s -L -H "$accept_json" -H "$auth" -H "$api_ver" $url/releases/$rel_id/assets | jq -r '.[0]')
asset_id=$(jq -r '.id' <<< "$asset")
asset_name=$(jq -r '.name' <<< "$asset")
echo "Asset: $asset_id / $asset_name"

if [ ! -n "$output_file" ]; then
    output_file=$asset_name
fi

curl -L -H "$accept_stream" -H "$auth" -H "$api_ver" $url/releases/assets/$asset_id >> $output_file
