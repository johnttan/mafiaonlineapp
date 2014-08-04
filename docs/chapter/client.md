# Client

---

The client is built on top of AngularJS. I used Angular because it structures the code in a robust and purposeful way, while remaining flexible. GameService is responsible for storing game state and interacting with Socket.io.

Semantic UI CSS framework is used for most of the styling.

**GameService** contains 3 primary socket connections, the main socket, matchmaking socket, and game socket. The game socket is connected to a unique namespace for the game when a game is found.

The **joinQueue** method assigns the event handlers to the socket connection when a "match_found" event is received on the matchmaking socket. It also initiates the queue process by emitting 'joinQueue' on the matchmaking socket.
