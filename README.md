# Werewolves of Cairo 

Recreation of the game Werewolves of Millers Hollow on the Starknet blockchain using Dojo.

## Get started

```bash
# start katana local server
katana --disable-fee
# build & migrate
sozo build
sozo migrate

# start indexer
torii --world {world_address}

# setup default auth
./scripts/default_auth.sh

# start frontend
cd web
# install & start server using any package manager
bun install && bun dev
```
