#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

export RPC_URL="http://localhost:5050";

export WORLD_ADDRESS=$(cat ./contracts/target/dev/manifest.json | jq -r '.world.address')
export GAME_ADDRESS=$(cat ./contracts/target/dev/manifest.json | jq -r '.contracts[] | select(.name == "game" ).address')
export LOBBY_ADDRESS=$(cat ./contracts/target/dev/manifest.json | jq -r '.contracts[] | select(.name == "lobby" ).address')
export PLAYER_ADDRESS=$(cat ./contracts/target/dev/manifest.json | jq -r '.contracts[] | select(.name == "player" ).address')
export PROFILE_ADDRESS=$(cat ./contracts/target/dev/manifest.json | jq -r '.contracts[] | select(.name == "profile" ).address')
export WAITER_ADDRESS=$(cat ./contracts/target/dev/manifest.json | jq -r '.contracts[] | select(.name == "waiter" ).address')


echo "---------------------------------------------------------------------------"
echo rpc  : $RPC_URL 
echo " "
echo world : $WORLD_ADDRESS 
echo " "
echo game : $GAME_ADDRESS
echo lobby : $LOBBY_ADDRESS
echo player : $PLAYER_ADDRESS
echo profile : $PROFILE_ADDRESS
echo waiter : $WAITER_ADDRESS
echo "---------------------------------------------------------------------------"


GAME_MODELS=("Game" "Market" "Player" )
LOBBY_MODELS=("Player" "Market" "Encounter")
PLAYER_MODELS=("Player" "Drug" "Market" "Encounter")
PROFILE_MODELS=("Drug" "Market" "Player")
WAITER_MODELS=("Player" "Item" "Market")

for model in ${LOBBY_MODELS[@]}; do
    sozo auth writer $model $LOBBY_ADDRESS --world $WORLD_ADDRESS --rpc-url $RPC_URL
    sleep 0.1
done


echo "Default authorizations have been successfully set."