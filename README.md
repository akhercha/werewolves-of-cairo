# Werewolves of Cairo 

Recreation of the game Werewolves of Millers Hollow on the Starknet blockchain using Dojo.

[[Architecture documentation]](docs/architecture.md)

[[Figma folder]](https://www.figma.com/files/project/115049883/Werwolves-of-Cairo?fuid=1049275643167208739)

## Get started

```bash
# start katana local server
katana --disable-fee

# build & migrate
cd contracts
sozo build
sozo migrate

# start indexer
torii --world {world_address}

# setup default auth
cd ..
./scripts/default_auth.sh

# start frontend
cd web
# install & start server using any package manager
bun install && bun dev
```
