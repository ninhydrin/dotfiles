# etc=/Applications/Docker.app/Contents/Resources/etc
# ln -s $etc/docker.zsh-completion /usr/local/share/zsh/site-functions/_docker
# ln -s $etc/docker-compose.zsh-completion /usr/local/share/zsh/site-functions/_docker-compose

zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes