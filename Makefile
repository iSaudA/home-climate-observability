SHELL := /usr/bin/env bash

.PHONY: bootstrap up down restart up-ha down-ha up-observability down-observability validate test logs status backup
bootstrap:
	./scripts/bootstrap.sh
up:
	docker compose up -d
down:
	docker compose down
restart: down up
up-ha:
	docker compose -f home-automation/compose.yaml up -d
down-ha:
	docker compose -f home-automation/compose.yaml down
up-observability:
	docker compose -f observability/compose.yaml up -d
down-observability:
	docker compose -f observability/compose.yaml down
validate:
	./scripts/validate.sh
test:
	PYTHONPATH=. python3 -m pytest
logs:
	docker compose logs -f --tail=100
status:
	docker compose ps
backup:
	./scripts/backup.sh
