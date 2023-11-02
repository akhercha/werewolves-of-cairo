# Game loop

Below is a rough outline of the game loop:

```mermaid
flowchart TD
    Start[Create Game Lobby] -->|Other Players Join|B[Setup Game]
    B -->|Start Game and Assign Roles Randomly|R[Game Starts]
    R -->D[Day 1]
    D -->|Events of the Day|E[Day 2]
    E -->|Next Day's Events|F[Day n]
    F -->|Events of the Day|G[Someone Wins]
    G -->|If villagers win|V[Villagers Win]
    G -->|If wolves win|W[Wolves Win]
```

# Models

Doesn't include any specific things related to blockchains/dojo for now (e.g. player addresses, etc.):

```mermaid
graph LR
  subgraph "Lobby Model"
    Lobby["Lobby 
    -------
    Status: 
      - Open
      - Closed
    Player List: 
      - players"]
  end
  subgraph "Player Model"
    Player["Player 
    -------
    Status: 
      - In Lobby
      - In Game
    Role: 
      - Not Assigned
      - Villager
      - Werewolf
    Alive Status: 
      - Alive
      - Dead
    Vote: 
      - Player ID"]
  end
  subgraph "Game Model"
    Game["Game 
    -------
    Status: 
      - Active
      - Ended
    Current Day: 
      - day"]
  end
  subgraph "Day Model"
    Day["Day 
    -------
    Status: 
      - Active
      - Ended
    Events: 
      - events"]
  end
  Lobby --> Player
  Player --> Game
  Game --> Day
  Day --> Day[Next Day]
```
