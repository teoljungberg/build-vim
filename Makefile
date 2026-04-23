SHELL := /bin/sh
.DEFAULT_GOAL := help

ifdef DEBUG
  OUTPUT := /dev/stderr
else
  OUTPUT := /dev/null
endif

PREFIX ?= $(HOME)/.local
UPDATE_MAX_AGE_MIN ?= 360 # == 6h
VIM_DIR := tmp/vim
VIM_URL := https://github.com/vim/vim
NVIM_DIR := tmp/neovim
NVIM_URL := https://github.com/neovim/neovim

.PHONY: help
help: ## Display this help.
	@ grep -E '^[a-zA-Z_-]+:.*?##.*$$' $(MAKEFILE_LIST) | sed 's/.*## //'

.PHONY: build-vim
build-vim: ## Configure and build `vim(1)` without installing.
build-vim: check-vim clone-vim
	@ cd "$(VIM_DIR)" && \
	  ./configure \
	    --prefix="$(PREFIX)" \
	    --enable-autoservername \
	    --enable-cscope \
	    --enable-fail-if-missing \
	    --enable-fontset \
	    --enable-multibyte \
	    --enable-python3interp=dynamic \
	    --enable-rubyinterp \
	    --enable-terminal \
	    --with-compiledby="teoljungberg" \
	    --with-features=huge \
	    --with-python3-command=/usr/bin/python3 \
	    --with-ruby-command=/usr/bin/ruby \
	    >$(OUTPUT) 2>&1 && \
	  $(MAKE) >$(OUTPUT) 2>&1

.PHONY: build-nvim
build-nvim: ## Configure and build `nvim(1)` without installing.
build-nvim: check-nvim clone-nvim
	@ cd "$(NVIM_DIR)" && \
	  $(MAKE) CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX="$(PREFIX)" >$(OUTPUT) 2>&1

.PHONY: check-vim
check-vim: ## Ensure the system can build `vim(1)`.
	@ command -v git >/dev/null 2>&1 || { echo >&2 "The command \`git\` does not exist."; exit 1; }
	@ command -v ruby >/dev/null 2>&1 || { echo >&2 "The command \`ruby\` does not exist."; exit 1; }

.PHONY: check-nvim
check-nvim: ## Ensure the system can build `nvim(1)`.
	@ command -v git >/dev/null 2>&1 || { echo >&2 "The command \`git\` does not exist."; exit 1; }
	@ command -v cmake >/dev/null 2>&1 || { echo >&2 "The command \`cmake\` does not exist."; exit 1; }

.PHONY: clean
clean: ## Remove checked out sources.
	@ rm -rf "$(VIM_DIR)" "$(NVIM_DIR)"

.PHONY: distclean-vim
distclean-vim: ## Remove `vim(1)` build caches without re-cloning.
	@ if [ -d "$(VIM_DIR)" ] && [ -f "$(VIM_DIR)/src/auto/config.cache" ]; then \
	    cd "$(VIM_DIR)" && $(MAKE) distclean >$(OUTPUT) 2>&1; \
	  fi

.PHONY: distclean-nvim
distclean-nvim: ## Remove `nvim(1)` build caches without re-cloning.
	@ rm -rf "$(NVIM_DIR)/build" "$(NVIM_DIR)/.deps"

$(VIM_DIR): | check-vim
	@ echo "Cloning $(VIM_URL)"
	@ git clone --quiet $(VIM_URL) "$(VIM_DIR)"

.PHONY: clone-vim
clone-vim: ## Checkout `vim(1)` locally if missing.
clone-vim: $(VIM_DIR)

$(NVIM_DIR): | check-nvim
	@ echo "Cloning $(NVIM_URL)"
	@ git clone --quiet $(NVIM_URL) "$(NVIM_DIR)"

.PHONY: clone-nvim
clone-nvim: ## Checkout `nvim(1)` locally if missing.
clone-nvim: $(NVIM_DIR)

.PHONY: should-update-vim
should-update-vim: ## Update `vim(1)` if the checkout is stale.
should-update-vim: clone-vim
	@ last=$$(git -C "$(VIM_DIR)" log -1 --format=%ct 2>/dev/null || echo 0); \
	  if [ $$(( $$(date +%s) - last )) -gt $$(($(UPDATE_MAX_AGE_MIN) * 60)) ]; then \
	    $(MAKE) update-vim; \
	  fi

.PHONY: should-update-nvim
should-update-nvim: ## Update `nvim(1)` if the checkout is stale.
should-update-nvim: clone-nvim
	@ last=$$(git -C "$(NVIM_DIR)" log -1 --format=%ct 2>/dev/null || echo 0); \
	  if [ $$(( $$(date +%s) - last )) -gt $$(($(UPDATE_MAX_AGE_MIN) * 60)) ]; then \
	    $(MAKE) update-nvim; \
	  fi

.PHONY: update-vim
update-vim: ## Force-update the `vim(1)` checkout.
update-vim: clone-vim
	@ echo "Updating $(VIM_URL)"
	@ git -C "$(VIM_DIR)" fetch --quiet origin
	@ current=$$(git -C "$(VIM_DIR)" rev-parse --short HEAD); \
	  new=$$(git -C "$(VIM_DIR)" rev-parse --short origin/HEAD); \
	  if [ "$$current" != "$$new" ]; then \
	    echo "$(VIM_URL)/compare/$$current...$$new"; \
	  fi
	@ git -C "$(VIM_DIR)" rebase --quiet origin/HEAD >"$(OUTPUT)" 2>&1

.PHONY: update-nvim
update-nvim: ## Force-update the `nvim(1)` checkout.
update-nvim: clone-nvim
	@ echo "Updating $(NVIM_URL)"
	@ git -C "$(NVIM_DIR)" fetch --quiet origin
	@ current=$$(git -C "$(NVIM_DIR)" rev-parse --short HEAD); \
	  new=$$(git -C "$(NVIM_DIR)" rev-parse --short origin/HEAD); \
	  if [ "$$current" != "$$new" ]; then \
	    echo "$(NVIM_URL)/compare/$$current...$$new"; \
	  fi
	@ git -C "$(NVIM_DIR)" rebase --quiet origin/HEAD >"$(OUTPUT)" 2>&1

.PHONY: install-vim
install-vim: ## Clone, build, and install `vim(1)`.
install-vim: should-update-vim build-vim
	@ cd "$(VIM_DIR)" && $(MAKE) install >$(OUTPUT) 2>&1

.PHONY: install-nvim
install-nvim: ## Clone, build, and install `nvim(1)`.
install-nvim: should-update-nvim build-nvim
	@ cd "$(NVIM_DIR)" && $(MAKE) install CMAKE_INSTALL_PREFIX="$(PREFIX)" >$(OUTPUT) 2>&1
