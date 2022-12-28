ZSH_THEME="billy"
plugins=(git)

export ZSH="$HOME/.oh-my-zsh"
export PATH=~/.local/bin:$PATH
export PATH=$PATH:~/tools/lua-language-server-3.2.4-linux-x64/bin/
export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
export VISUAL=nvim
export EDITOR=nvim
export NVM_DIR="$HOME/.nvm"
export PATH=$PATH:/home/omegalord666/.spicetify
# export PATH="$PATH:$(yarn global bin)"

alias v="nvim"
alias lg="lazygit"
alias w1="cd ~/work/majoo-ui"
alias w2="cd ~/work/myklopos"
alias w3="cd ~/work/backup/myklopos"
alias p1="cd ~/personal/2022/bws"
alias p2="cd ~/personal/2022/laravel.hkabwssumvi.id"
alias q="cd ~/QuickScript/"
alias q1="~/QuickScript/mysql.sh"
alias config='/usr/bin/git --git-dir=/home/omegalord666/.cfg/ --work-tree=/home/omegalord666'

source $HOME/.zsh/aliases
source $HOME/.cargo/env 2> /dev/null
source $ZSH/oh-my-zsh.sh

echo "Custom Command \n\e[31mv\e[0m for \e[35mneovim\e[0m\n\e[31mlg\e[0m for \e[36mLazygit\e[0m"
echo "Quick Script start with \e[31mq\e[0m"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [[ ! $TERM_PROGRAM =~ tmux ]] 
then
    tmux attach || tmux
fi
