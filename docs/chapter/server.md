# Server

---

Clients connect to games by connecting to a Socket.IO namespace (generated randomly with UUID). Each player belongs to the "public" Socket.io room, where they can receive public chat messages during the day or before the game. Players with roles that have night meetings will also belong to a private room such as "mafia".

All network transactions for the game go through Socket.IO.
