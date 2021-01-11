# Makefile for Docker poser Workspace

#include .env
# MySQL
MYSQL_DUMPS_DIR=./dumps
MYSQL_ROOT_USER=root
MYSQL_ROOT_PASSWORD=root
DOCKER_IMAGE=orendev/php-base:latest-7.3

docker-build:
	@chmod +x ./build.sh
	@./build.sh
	@docker build . --file ./docker/php-base/Dockerfile --tag "${DOCKER_IMAGE}"
	@docker-compose build

docker-push:
	@docker push "${DOCKER_IMAGE}"

docker-start:
	@docker-compose up -d

docker-stop:
	@docker-compose stop

docker-down:
	@make mysql-dump
	@docker-compose down -v

phpmd:
	docker-compose exec --user=bxdock php-cli bash

composer-in:
	@docker run --rm -v $(shell pwd)/public:/app composer install
	
composer-up:
	@docker run --rm -v $(shell pwd)/public:/app composer update

mysql-dump:
	@mkdir -p $(MYSQL_DUMPS_DIR)
	@docker exec $(shell docker-compose ps -q mysql) mysqldump --all-databases -u"$(MYSQL_ROOT_USER)" -p"$(MYSQL_ROOT_PASSWORD)" > $(MYSQL_DUMPS_DIR)/db.sql 2>/dev/null

mysql-restore:
	@docker exec -i $(shell docker-compose ps -q mysql) mysql -u"$(MYSQL_ROOT_USER)" -p"$(MYSQL_ROOT_PASSWORD)" < $(MYSQL_DUMPS_DIR)/db.sql 2>/dev/null