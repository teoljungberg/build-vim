.DEFAULT_GOAL := help

build: ## Configure and build `vim(1)` without installing.
build: check clone
	@ bin/build

check: ## Ensures that the system can build `vim(1)`.
	@ bin/check

clean: ## Remove checked out version of `vim(1)`.
	rm -rf tmp/vim

clone: ## Checkout `vim(1)` locally.
clone: check
	@ bin/clone

help: ## Display this help.
	@ grep -E "^[a-zA-Z_-]+:.*?##.*$$" $(MAKEFILE_LIST) | grep -v grep | sed 's/## //'

lint: ## Lint all shell scripts.
	@ bin/lint

install: ## Clone, build, and install `vim(1)`.
install: build
	@ bin/install

update: ## Same as `make install`.
update: install
