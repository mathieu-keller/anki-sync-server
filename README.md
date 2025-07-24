# anki-sync-server
This is an docker build repo for the Anki sync server from this repo: https://github.com/ankitects/anki/tree/main
Documentation can be found [here](https://docs.ankiweb.net/sync-server.html)

## tl:dr:
```dockerfile
version: "3"
services:
  server:
    image: afrima/anki-sync-server:25.07.4
    container_name: anki-sync-server
    environment:
      - SYNC_USER1=test_user_name:test_user_password
      - SYNC_PORT=8080
      - SYNC_BASE=/data
    restart: always
    volumes:
      - <your path>:/data
    ports:
      - "1337:8080"
```