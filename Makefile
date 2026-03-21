SHELL := /bin/sh
.DEFAULT_GOAL := help

ifdef DEBUG
  OUTPUT := /dev/stderr
else
  OUTPUT := /dev/null
endif

VIM_DIR := tmp/vim
VIM_URL := https://github.com/vim/vim
NVIM_DIR := tmp/neovim
NVIM_URL := https://github.com/neovim/neovim

.PHONY: help
help: ## Display this help.
	@ grep -E "^[a-zA-Z_-]+:.*?##.*$$" $(MAKEFILE_LIST) | grep -v grep | sed 's/## //'

.PHONY: build-vim
build-vim: ## Configure and build `vim(1)` without installing.
build-vim: check-vim clone-vim
	@ cd $(VIM_DIR) && \
	  ./configure \
	    --enable-cscope \
	    --enable-fail-if-missing \
	    --enable-fontset \
	    --enable-multibyte \
	    --enable-rubyinterp \
	    --enable-terminal \
	    --with-compiledby="teoljungberg" \
	    --with-features=huge \
	    --with-ruby-command=/usr/bin/ruby \
	    1>$(OUTPUT) 2>$(OUTPUT) && \
	  $(MAKE) 1>$(OUTPUT) 2>$(OUTPUT)

.PHONY: build-nvim
build-nvim: ## Configure and build `nvim(1)` without installing.
build-nvim: check-nvim clone-nvim
	@ cd $(NVIM_DIR) && \
	  cmake -S . -B build -DCMAKE_BUILD_TYPE=Release 1>$(OUTPUT) 2>$(OUTPUT) && \
	  cmake --build build 1>$(OUTPUT) 2>$(OUTPUT)

.PHONY: check-vim
check-vim: ## Ensure the system can build `vim(1)`.
	@ command -v git >/dev/null 2>&1 || { echo >&2 "The command \`git\` does not exist."; exit 1; }
	@ command -v ruby >/dev/null 2>&1 || { echo >&2 "The command \`ruby\` does not exist."; exit 1; }

.PHONY: check-nvim
check-nvim: ## Ensure the system can build `nvim(1)`.
	@ command -v git >/dev/null 2>&1 || { echo >&2 "The command \`git\` does not exist."; exit 1; }
	@ command -v cmake >/dev/null 2>&1 || { echo >&2 "The command \`cmake\` does not exist."; exit 1; }
	@ pkg-config --exists tree-sitter 2>/dev/null || { echo >&2 "The library \`tree-sitter\` is not installed."; exit 1; }

.PHONY: clean
clean: ## Remove checked out sources.
	@ rm -rf $(VIM_DIR) $(NVIM_DIR)

.PHONY: clone-vim
clone-vim: ## Checkout `vim(1)` locally.
clone-vim: check-vim
	@ if [ -d $(VIM_DIR) ]; then \
	    echo "Updating $(VIM_URL)"; \
	    git -C $(VIM_DIR) fetch --quiet origin; \
	    current=$$(git -C $(VIM_DIR) rev-parse --short HEAD); \
	    new=$$(git -C $(VIM_DIR) rev-parse --short origin/master); \
	    if [ "$$current" != "$$new" ]; then \
	      echo "$(VIM_URL)/compare/$$current...$$new"; \
	    fi; \
	    git -C "$(VIM_DIR)" rebase --quiet origin/master >"$(OUTPUT)" 2>&1; \
	  else \
	    echo "Cloning $(VIM_URL)"; \
	    git clone --quiet $(VIM_URL) $(VIM_DIR); \
	  fi

.PHONY: clone-nvim
clone-nvim: ## Checkout `nvim(1)` locally.
clone-nvim: check-nvim
	@ if [ -d $(NVIM_DIR) ]; then \
	    echo "Updating $(NVIM_URL)"; \
	    git -C $(NVIM_DIR) fetch --quiet origin; \
	    current=$$(git -C $(NVIM_DIR) rev-parse --short HEAD); \
	    new=$$(git -C $(NVIM_DIR) rev-parse --short origin/main); \
	    if [ "$$current" != "$$new" ]; then \
	      echo "$(NVIM_URL)/compare/$$current...$$new"; \
	    fi; \
	    git -C "$(NVIM_DIR)" rebase --quiet origin/main >"$(OUTPUT)" 2>&1; \
	  else \
	    echo "Cloning $(NVIM_URL)"; \
	    git clone --quiet $(NVIM_URL) $(NVIM_DIR); \
	  fi

.PHONY: install-vim
install-vim: ## Clone, build, and install `vim(1)`.
install-vim: build-vim
	@ cd $(VIM_DIR) && $(MAKE) install 1>$(OUTPUT) 2>$(OUTPUT)

.PHONY: install-nvim
install-nvim: ## Clone, build, and install `nvim(1)`.
install-nvim: build-nvim
	@ cd $(NVIM_DIR) && cmake --install build 1>$(OUTPUT) 2>$(OUTPUT)
