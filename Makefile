DOTPATH    := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
CANDIDATES := $(wildcard .??*) bin
# .config は丸ごとsymlinkせず、deploy内の個別処理でサブディレクトリ単位にリンクする
# （丸ごとsymlinkすると ~/.config が無い新規マシンで個別リンクが自己参照になり ln が失敗する）
EXCLUSIONS := .DS_Store .git .gitmodules .travis.yml .Trash .config
DOTFILES   := $(filter-out $(EXCLUSIONS), $(CANDIDATES))

all: install

help:
	@echo "make list           #=> Show dot files in this repo"
	@echo "make deploy         #=> Create symlink to home directory"
	@echo "make init           #=> Setup environment settings"
	@echo "make test           #=> Test dotfiles and init scripts"
	@echo "make update         #=> Fetch changes for this repo"
	@echo "make install        #=> Run make update, deploy, init"
	@echo "make clean          #=> Remove the dot files and this repo"

list:
	@$(foreach val, $(DOTFILES), /bin/ls -dF $(val);)

deploy:
	@echo '==> Start to deploy dotfiles to home directory.'
	@echo ''
	@$(foreach val, $(DOTFILES), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)
	@mkdir -p $(HOME)/.proto
	@ln -sfnv $(abspath .prototools) $(HOME)/.proto/.prototools
	@ln -sfnv $(abspath my_env_files) $(HOME)/.env.d
	@if [ -L $(HOME)/.config ]; then \
		echo '==> Replacing legacy ~/.config symlink with a real directory'; \
		rm $(HOME)/.config; \
	fi
	@if [ -d .config ]; then \
		echo '==> Deploying .config directories...'; \
		mkdir -p $(HOME)/.config; \
		for dir in .config/*; do \
			if [ -d "$$dir" ] && [ "$$dir" != ".config/herdr" ]; then \
				target=$$(basename "$$dir"); \
				ln -sfnv $(abspath $$dir) $(HOME)/.config/$$target; \
			fi; \
		done; \
	fi
	@# herdr はランタイムファイル（ログ・ソケット等）が ~/.config/herdr に置かれるため
	@# ディレクトリごとではなく config.toml のみリンクする
	@mkdir -p $(HOME)/.config/herdr
	@ln -sfnv $(abspath .config/herdr/config.toml) $(HOME)/.config/herdr/config.toml

init:
	@DOTPATH=$(DOTPATH) bash $(DOTPATH)/etc/init/init.sh

test:
	@DOTPATH=$(DOTPATH) bash $(DOTPATH)/etc/test/test.sh

update:
	git pull origin master

install: update deploy init
	@exec $$SHELL

clean:
	@echo 'Remove dot files in your home directory...'
	@-$(foreach val, $(DOTFILES), rm -vrf $(HOME)/$(val);)
	-rm -rf $(DOTPATH)
