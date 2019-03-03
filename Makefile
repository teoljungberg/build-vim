.DEFAULT_GOAL := help

clean: ## Remove checked out version of `vim(1)`.
	rm -rf tmp/vim

clone: ## Checkout `vim(1)` locally.
	@bin/clone

compile: ## Configure and compile `vim(1)`.
	@bin/compile

help: ## Display this help.
	@grep -E "^[a-zA-Z_-]+:.*?##.*$$" $(MAKEFILE_LIST) | grep -v grep | sed 's/## //'

lint: ## Lint all shell scripts.
	@bin/lint

install: ## Clone and compile.
install: clone compile
