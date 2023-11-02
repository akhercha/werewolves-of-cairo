# Game loop

```mermaid
flowchart TD
    Start[Create Lobby] -->|Players Join Lobby|A[Setup Lobby(Model: Lobby, Status: Open, Player List: players)]
    A -->|Start Game|B[Game Starts (Model: Game, Status: Active)]
    B -->|Assign Roles|C1[Player Model Updates (Status: In Game, Role: Assigned)]
    C1 -->|Start Day|D[Day Starts (Model: Day, Status: Active)]
    D -->|Cast Votes|E[Player Model Updates (Vote Cast)]
    E -->|Resolve Votes|F[Kill Player (Model: Player, Status: Dead) or Continue with Next Day]
    F -->|Check Win Condition|G[Game Status Update (Villagers Win or Wolves Win)]
    G -->|If Game Continues|D
    G -->|If Game Ends|End[Game Ends]
```

# Models

```mermaid
graph TD
    Lobby{Lobby<br/>Status: Open/Closed<br/>Player List: players} --> Player
    Player{Player<br/>Status: In Lobby/In Game<br/>Role: Not Assigned/Villager/Werewolf<br/>Alive Status: Alive/Dead<br/>Vote: Player ID} --> Game
    Game{Game<br/>Status: Active/Ended<br/>Current Day: day} --> Day
    Day{Day<br/>Status: Active/Ended<br/>Events: events} -->|Next| Day
```
