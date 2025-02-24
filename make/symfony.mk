
### ——————————————————————————————————————————————————————————————————
### —— Symfony Projects Basic Actions
### ——————————————————————————————————————————————————————————————————

# Symfony App Container
APP_CONTAINER ?= "app"
# List Of Symfony Containers
SF_CONTAINERS ?= ""
# Symfony Console Command
SF_CONSOLE := php bin/console

## Render List of Available Containers
.PHONY: sf-list
sf-list:
	@echo "Symfony Containers : $(SF_CONTAINERS)"

.PHONY: cc
cc: ## Apply cache clear on all Symfony Containers
	$(MAKE) sf-list
	$(MAKE) cc-sf-local
	@for ID in $(SF_CONTAINERS) ; do CONTAINER=$$ID $(MAKE) cc-sf-node ; done

cc-sf-node: # Clear Cache on a Symfony Node
	@echo "Symfony - Clear Cache on $(CONTAINER)";
	@$(DOCKER_COMPOSE) exec $(CONTAINER) rm -Rf var/cache;
	@$(DOCKER_COMPOSE) exec $(CONTAINER) $(SF_CONSOLE) cache:clear;

cc-sf-local: # Clear Cache on a Symfony Node
	@echo "Symfony - Clear Cache Local";
	@rm -Rf var/cache;
	@$(SF_CONSOLE) cache:clear || exit 0;

doctrine-status:
	@echo "Symfony - Database Status on $(APP_CONTAINER)";
	@$(DOCKER_COMPOSE) exec $(APP_CONTAINER) $(SF_CONSOLE) doctrine:schema:update --complete --dump-sql;

doctrine-update:
	@echo "Symfony - Update Database on $(APP_CONTAINER)";
	@$(DOCKER_COMPOSE) exec $(APP_CONTAINER) $(SF_CONSOLE) doctrine:schema:update --complete --force;

#cc-test: ## Apply cache clear
#	$(DOCKER) sh -c "rm -rf var/cache"
#	$(CONSOLE_TEST) cache:clear
#	$(DOCKER) sh -c "chmod -R 777 var/cache"
#
#doctrine-validate:
#	$(CONSOLE) doctrine:schema:validate --skip-sync $c
#
#reset-database: drop-database database migrate load-fixtures ## Reset database with migration
#
#database: ## Create database if no exists
#	$(CONSOLE) migrate:status
#
#drop-database: ## Drop the database
#	$(CONSOLE) doctrine:database:drop --force --if-exists
#
#migration: ## Apply doctrine migration
#	$(CONSOLE) make:migration
#
#migrate: ## Apply doctrine migrate
#	$(CONSOLE) doctrine:migration:migrate -n --all-or-nothing
#
#generate-jwt: ## Generate private and public keys
#	$(CONSOLE) lexik:jwt:generate-keypair --overwrite -q $c
#