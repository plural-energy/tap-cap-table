#!/bin/bash

# Accept a single argument of an env file to use. By default use .env at root
USE_ENV_FILE=${1:-.env}

source $USE_ENV_FILE

# chain ID based on RPC_URL
chain_id=$(cast chain-id --rpc-url "$RPC_URL")

# Get the current timestamp
timestamp=$(date +%s)

# Create the deployment directory
deployment_dir="deployments/$chain_id/$timestamp"
mkdir -p "chain/$deployment_dir"

# Set the log file path
log_file="$deployment_dir/deploy.log"


# Copy the root .env underneath chain so we dont have to maintain two copies
TEMP=$PWD/chain/.env
cp $USE_ENV_FILE $TEMP
trap "rm $TEMP" EXIT

set -x
cd chain
forge script script/CapTableFactory.s.sol:DeployCapTableFactoryDeployLocalScript --broadcast --fork-url $RPC_URL --ast --out $deployment_dir -vvvv > $log_file 2>&1

rm -rf out
cp -r $deployment_dir out
echo "✅ Finished TAP Deployment! See out/deploy.log for details"
echo "TAP_TMP=chain/${deployment_dir}"
