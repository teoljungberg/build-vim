.DEFAULT_GOAL := help

build-vim: ## Configure and build `vim(1)` without installing.
build-vim: check-vim clone-vim
	@ bin/build-vim

build-nvim: ## Configure and build `nvim(1)` without installing.
build-nvim: check-nvim clone-nvim
	@ bin/build-nvim

check-vim: ## Ensures that the system can build `vim(1)`.
	@ bin/check-vim

check-nvim: ## Ensures that the system can build `nvim(1)`.
	@ bin/check-nvim

clean: ## Remove checked out versions of `vim(1)` and `nvim(1)`.
	rm -rf tmp/vim tmp/neovim

clone-vim: ## Checkout `vim(1)` locally.
clone-vim: check-vim
	@ bin/clone-vim

clone-nvim: ## Checkout `nvim(1)` locally.
clone-nvim: check-nvim
	@ bin/clone-nvim

help: ## Display this help.
	@ grep -E "^[a-zA-Z_-]+:.*?##.*$$" $(MAKEFILE_LIST) | grep -v grep | sed 's/## //'

lint: ## Lint all shell scripts.
	@ bin/lint

install-vim: ## Clone, build, and install `vim(1)`.
install-vim: build-vim
	@ bin/install-vim

install-nvim: ## Clone, build, and install `nvim(1)`.
install-nvim: build-nvim
	@ bin/install-nvim

update-vim: ## Same as `make install-vim`.
update-vim: install-vim

update-nvim: ## Same as `make install-nvim`.
update-nvim: install-nvim
