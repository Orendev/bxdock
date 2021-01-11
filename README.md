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
make docker-build

# Go to the server with hot reload at http://localhost/:
make docker-start

# Docker stop
make docker-stop

# Docker down
make docker-down

# docker-compose exec
make phpmd
```

## Project Structure:

* `public/` - folder web site
* `dumps/` - mysql dumps
* `docker/` - docker
* `bx/` - templates bitrix setup
