### ——————————————————————————————————————————————————————————————————
### —— Local Makefile
### ——————————————————————————————————————————————————————————————————

include make/sdk.mk

COMMAND ?= echo "Aucune commande spécifiée"
COLOR_CYAN := $(shell tput setaf 6)
COLOR_RESET := $(shell tput sgr0)

start: 	## Execute Functional Test
	symfony serve --no-tls

.PHONY: upgrade
upgrade:
	$(MAKE) up
	$(MAKE) all COMMAND="composer update -q"

.PHONY: verify
verify:	# Verify Code in All Containers
	$(MAKE) up
	$(MAKE) all COMMAND="composer update -q"
	$(MAKE) all COMMAND="php vendor/bin/grumphp run --testsuite=travis"
	$(MAKE) all COMMAND="php vendor/bin/grumphp run --testsuite=csfixer"
	$(MAKE) all COMMAND="php vendor/bin/grumphp run --testsuite=phpstan"

.PHONY: phpstan
phpstan:	# Execute Php Stan in All Containers
	$(MAKE) all COMMAND="php vendor/bin/grumphp run --testsuite=phpstan"

.PHONY: docker
docker:		# Compile & Push All Docker Containers
	bash docker/update.sh

.PHONY: all
all: # Execute a Command in All Containers
	@$(foreach service,$(shell docker compose config --services), \
		set -e; \
		echo "$(COLOR_CYAN) >> Executing '$(COMMAND)' in container: $(service) $(COLOR_RESET)"; \
		docker compose exec $(service) bash -c "$(COMMAND)"; \
	)