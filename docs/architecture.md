# Game loop

Below is a rough outline of the game loop:

```mermaid
flowchart TD
    Start[Create Game Lobby] -->|Other Players Join|B[Setup Game]
    B -->|Start Game and Assign Roles Randomly|R[Game Starts]
    R -->D[Day 1]
    D -->|Next Day's Events|E[Day n]
    E -->|End game triggered|F[Someone Wins]
```

# Models

Simple overview.

Currently miss a lot of details.

Doesn't include any specific things related to blockchains/dojo for now (e.g. player addresses, etc.):

```mermaid
graph LR
  subgraph "Player Model"
    Player["Player 
    -------
    - Player ID
    - Status
    - Lobby ID
    - Game ID
    - Role
    - Alive Status
    - Vote"]
  end
  subgraph "Lobby Model"
    Lobby["Lobby 
    -------
    - Lobby ID
    - Creator Player ID
    - Status
    - Player List"]
  end
  subgraph "Game Model"
    Game["Game 
    -------
    - Game ID
    - Lobby ID
    - Status
    - Current Day ID"]
  end
  subgraph "Day Model"
    Day["Day 
    -------
    - Day ID
    - Game ID
    - Status
    - Events"]
  end
  Player --> Lobby
  Lobby --> Game
  Game --> Day
  Day -.-> Day[Next Day]
```
