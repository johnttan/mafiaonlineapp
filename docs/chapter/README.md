# Architecture

The app is designed as a single page application that focuses on duplex Socket.io eventing to drive functionality. One of the critical issues with an online multiplayer game is that of maintaining and communicating reliable state. The architecture allows the server to maintain state and push updates while the client only has to send command events and manage the view upon receiving updates. This prevents most forms of cheating and allows greater separation of concerns in development.

####Contents

1. Game Engine
    * Details the game engine, where the meat of the application resides.
2. Client
    * Structure of the AngularJS front-end.
3. Server
    * Thin layer between the game engine and client.
