# Makefile for Docker poser Workspace

include .env

docker-build:
	@docker build . --file ./docker/php-base/Dockerfile --tag "orendev/php-base:latest-7.3"
	@docker-compose build

docker-push:
	@docker push "orendev/php-base:latest-7.3"

docker-start:
	@docker-compose up -d

docker-stop:
	@docker-compose down

phpcli-shel:
	docker-compose exec --user=bxdock php-cli bash

composer-in:
	@docker run --rm -v $(shell pwd)/public:/app composer install
	
composer-up:
	@docker run --rm -v $(shell pwd)/public:/app composer update

