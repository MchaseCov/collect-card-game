<div id="top"></div>

<h3 align="center">A Collectable Card Game Demo v0.1</h3>

  <p align="center">
    A personal project to create the strategic gameplay of a collectable card game in a Rails application!
    <br />
    <a href="https://github.com/MchaseCov/collect-card-game"><strong>Github Page »</strong></a>
    <br />
    <br />
    <a href="https://collect-card-game.herokuapp.com/">View Game Demo</a>
    ·
    <a href="https://github.com/MchaseCov/collect-card-game/issues">Report Bug</a>
    ·
    <a href="https://github.com/MchaseCov/collect-card-game/issues">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#gameplay">Gameplay</a>
      <ul>
        <li><a href="#decks-and-the-card-library">Decks and the Card Library</a></li>
        <li><a href="#game-queueing-and-creation">Game Queueing and Creation</a></li>
        <li><a href="#mulligan-phase">Mulligan Phase</a></li>
        <li><a href="#core-gameplay-loop">Core Gameplay Loop</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## About The Project

![Gameplay Example Gif](https://i.imgur.com/lenerbS.gif)

Note: This project is intended for a personal hobby project and is not intended to grow into a regularly played game.

This project seeks to create a fun and strategic game in your web browser. Players can create decks from a variety of cards and engage in battle against other players using their decks. The game takes heavily inspiration from other games in this genre, such as Magic: The Gathering, Hearthstone, Yu-Gi-Oh, and more.

<p align="right">(<a href="#top">back to top</a>)</p>

### Built With

- [Ruby on Rails](https://rubyonrails.org/): Main framework of application
- [React.js](https://reactjs.org/): Recieves JSON over websocket to generate and update the HTML for the current gamestate
- [Hotwire](https://hotwired.dev/): Used for animating elements alongside React and streaming updates related to deck creation.
- [IndexedDB API](https://www.w3.org/TR/IndexedDB/): Used to store simple key-value object data on the client's side to lighten the load on the server database.
- [PostgreSQL](https://www.postgresql.org/): Used to store card, user, and game data.
- [Redis](https://redis.io/): For preserving game data in cache as well as a dependency for Hotwire Turbo Streams.
- [TailwindCSS](https://tailwindcss.com/): CSS and general aesthetics
- [Heroku](https://www.heroku.com/): Hosting the production version of the application.

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- GAMEPLAY -->

## Gameplay

This section details the various pieces and steps that take place to create and participate in a game

### Decks and the Card Library

The core of all gameplay revolves around cards. To play in a game, a player must first make a deck of cards! Decks consist of 30 cards (At this stage in development, there is no limit on duplicate cards in a deck). When creating a deck, players also choose a Race and Archetype. Races provide racial bonuses. These are small bonuses that can accentuate a deck's strategy, such as a small bonus to health or spendable coins. Archetypes, or "classes", dictate the cards a deck is allowed to run. A Wizard-Archetype deck cannot use cards in the Ranger-Archetype pool. All decks can run cards in the Neutral archetype pool. This allows every archetype to have their own unique theme and synergies.

### Game Queueing and Creation

Games are created from two queued decks. The decks contain the data that populates the game with its cards, decks, players, and initial stats for the players.

On the home page, players can select a deck to queue. The queue validates that the deck provided has 30 cards and then places the player in queue. When a second player joins the queue, the two players recieve a redirect over a websocket connection to their newly-created game.

### Mulligan Phase

At the start of a new game, players are redirected to the mulligan menu. Players are offered an initial hand of cards from their deck. Players can opt to keep the hand or exchange all the cards for new cards. The new hand of cards is the same amount as the first hand of cards, but all cards will be exchanged.

### Core Gameplay Loop

The core gameplay loop consists of each player taking alternating turns.

At the start of every turn:

- The player's coin cap increases by 1, up to 10.
- The player's resource point increases by 1, up to 10.
- The player's amount of coins to spend is refreshed to their cap.
- The player's amount of resource points to spend increases by 1, up to the current cap.
- The player draws one card.
- Any party members in battle 'wake up' and are ready to attack the opponent.

On a players turn they may:

- Spend coins on party cards, 'recruiting' them as a party member to battle for them.
- Spend resource points on powerful spells and effects.
- Command party members in the battlefield to attack the opposing player or their party

A player can only hold up to 10 cards in their hand and only command up to 7 party members on the battlefield at a time.
If a player's deck is empty and they attempt to draw a card, they will instead take half of their current health in damage, rounding down.

Players alternate turns and battle until one player's life total reaches 0.

### Keywords

Cards may have powerful keywords on them. Keywords can have effects like "deal damage" or "draw a card". The keyword's trigger is different for every type of keyword. The current keywords are:

- Aura: The aura effect is constantly active as long as the card that invoked the aura remains in play.
  - Example: A card that makes your other cards cheaper while it is in play.
- Battlecry: When a Party card with a battlecry is played to the battlefield, the battlecry effect triggers.
  - Example: A card that damages an opponent's card of your choice when you play it.
- Cast: Similar to a battlecry, but for spell cards. All spell cards have a cast effect.
  - Example: A spell that deals damage to the enemy player's entire battlefield.
- Deathrattle: When a Party card with a deathrattle dies in the battlefield, the deathrattle effect triggers.
  - Example: A card that spawns more party members into the battlefield when it dies.
- Listener: Similar to auras, a listener effect is active as long as the invoking card is in play. The difference is that listeners will trigger every time their condition is met.
  - Example: A card that gains stats every single time you play a spell'
- Listener: A party card with taunt that is in the battlefield must be attacked first.
  - Example: The opponent has a card with taunt in the battlefield, protecting the opponent player from being attacked by you.

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- ROADMAP -->

## Roadmap

- [ ] Sitewide navigation and aesthetic overhaul.
  - [ ] Improve accessability for non-standard devise resolutions.
  - [ ] Improve accessability for screen readers and similar technologies.
- [ ] Game-related front end changes.
  - [ ] (Under Consideration) Transistion remaining Stimulus structure to React-based structure.
  - [ ] Reorganize Javascript files with better use of Importmaps to reduce loading.
  - [ ] Add more informative tooltips.
  - [ ] Polish CSS related to the 3D game view.
  - [ ] Provide support for browsers that do not allow use of IndexedDB.
- [ ] Game-related back end changes.
  - [ ] (Under Consideration) Add a variety of 'tags' to cards for simpler keyword target filtration.
- [ ] Single Player mode.
  - [x] Create basic AI that makes legal, yet random, moves.
  - [ ] Create data to weigh AI decision making.

See the [open issues](https://github.com/MchaseCov/collect-card-game/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- CONTACT -->

## Contact

Chase Covington - [LinkedIn](https://www.linkedin.com/in/chase-covington-784886228/) - mchasecov@gmail.com

Project Link: [https://github.com/MchaseCov/collect-card-game](https://github.com/MchaseCov/collect-card-game)

Project Demo: [https://collect-card-game.herokuapp.com/](https://collect-card-game.herokuapp.com/)

<p align="right">(<a href="#top">back to top</a>)</p>
