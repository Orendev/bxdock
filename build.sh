#!/usr/bin/env bash

if ! [[ -f ./.env ]]; then
    cp ./.env_example ./.env
fi

if ! [[ -d ./public ]]; then
  mkdir ./public
  cp ./bx/* ./public/
fi