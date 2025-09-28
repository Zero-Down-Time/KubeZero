#!/bin/bash

jq -R 'split(".") | .[1] | @base64d | fromjson' <<< $(cat $1)
