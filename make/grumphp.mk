
### ——————————————————————————————————————————————————————————————————
### —— Code Quality - Init
### ——————————————————————————————————————————————————————————————————

GRUMPHP_SOURCES := bin/grumphp vendor/bin/grumphp
define find_grumphp_binary
	$(eval GRUMPHP_PATH :=)
	$(foreach FILE,$(1), \
	  $(if $(wildcard $(FILE)), \
		$(eval GRUMPHP_PATH := $(FILE)) \
		$(eval $(break)) \
	  ) \
	)
	$(GRUMPHP_PATH)
endef
GRUMPHP_BIN := $(call find_grumphp_binary,$(GRUMPHP_SOURCES))

### ——————————————————————————————————————————————————————————————————
### —— Code Quality - Grumphp Actions
### ——————————————————————————————————————————————————————————————————

grumphp-init:
	@echo 'Grumphp Binary: $(GRUMPHP_PATH)'

lint: 	## Run All Code Linter Checks
	$(GRUMPHP_PATH) run --tasks=composer,phplint,jsonlint,xmllint,yamllint,twigcslint

style: 	## Run All Code Standards Checks
	$(GRUMPHP_PATH) run --tasks=phpcpd,phpcs,phpmd,phpcsfixer

stan: 	## Run PHPStan Checks
	$(GRUMPHP_PATH) run --tasks=phpstan

quality: ## Run Whole Quality Checks
	$(MAKE) grumphp-init;
	$(MAKE) lint;
	$(MAKE) style;
	$(MAKE) stan;
