#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

export RPC_URL="http://localhost:5050";

export ACCOUNT_ADDRESS="0x517ececd29116499f4a1b64b094da79ba08dfd54a3edaa316134c41f8160973"
export PRIVATE_KEY="0x1800000000300000180000000000030000000000003006001800006600"

export WORLD_ADDRESS=$(cat ./contracts/target/dev/manifest.json | jq -r '.world.address')
export GAMES_ADDRESS=$(cat ./contracts/target/dev/manifest.json | jq -r '.contracts[] | select(.name == "games" ).address')
export LOBBIES_ADDRESS=$(cat ./contracts/target/dev/manifest.json | jq -r '.contracts[] | select(.name == "lobbies" ).address')
export PROFILES_ADDRESS=$(cat ./contracts/target/dev/manifest.json | jq -r '.contracts[] | select(.name == "profiles" ).address')

echo "---------------------------------------------------------------------------"
echo rpc  : $RPC_URL 
echo " "
echo world : $WORLD_ADDRESS 
echo " "
echo games : $GAMES_ADDRESS
echo lobbies : $LOBBIES_ADDRESS
echo profiles : $PROFILES_ADDRESS
echo "---------------------------------------------------------------------------"

PROFILES_MODELS=("Profile")
LOBBIES_MODELS=("Profile" "Waiter" "Lobby")
GAMES_MODELS=("Lobby" "Waiter")

for model in ${PROFILES_MODELS[@]}; do
    sozo auth writer $model $PROFILES_ADDRESS --world $WORLD_ADDRESS --rpc-url $RPC_URL --account-address $ACCOUNT_ADDRESS --private-key $PRIVATE_KEY
    sleep 0.1
done

for model in ${LOBBIES_MODELS[@]}; do
    sozo auth writer $model $LOBBIES_ADDRESS --world $WORLD_ADDRESS --rpc-url $RPC_URL --account-address $ACCOUNT_ADDRESS --private-key $PRIVATE_KEY
    sleep 0.1
done

for model in ${GAMES_MODELS[@]}; do
    sozo auth writer $model $GAMES_ADDRESS --world $WORLD_ADDRESS --rpc-url $RPC_URL --account-address $ACCOUNT_ADDRESS --private-key $PRIVATE_KEY
    sleep 0.1
done

echo "Default authorizations have been successfully set."
