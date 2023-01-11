insert:
	PGPASSWORD=postgres psql -h localhost -U postgres test -f ./create.sql

shell:
	PGPASSWORD=postgres psql -h localhost -U postgres test

up:
	docker compose up -d

down:
	docker compose down

loop:
	PGPASSWORD=postgres psql -h localhost -U postgres test -f ./loop.sql
