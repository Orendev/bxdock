<div align="center">
  <h1>Docker Bitrix</h1>
  <p>
    Docker is a cms bitrix. Images php 7.3, mysql 5.7, nginx, maildev.
  </p>
  <p>Docker bitrix: <a href="https://github.com/Orendev/bxdock">bxdock</a></p>
  <p>Author: <a href="https://orendev.ru" target="_blank">Orendev</a></p>
</div>

## Build Setup:

``` make
# Build docker:
make build

# Go to the server with hot reload at http://localhost/:
make up

# Docker stop
make stop

# Docker down
make down

# docker-compose exec
make php
```

## Project Structure:

* `public/` - folder web site
* `dumps/` - mysql dumps
* `docker/` - docker
* `bx/` - templates bitrix setup
