#!/bin/bash

SERVER=$1
EMR_DNS=$2
BROWSER="/Applications/Google Chrome.app"

nohup ssh -ND 8157 ${SERVER} &

echo "Launching verve-cc YARN Resource Manager"
open -a "${BROWSER}" "${EMR_DNS}:8088"

echo "Launching verve-cc Spark HistoryServer"
open -a "${BROWSER}" "${EMR_DNS}:18080"
