# Setup fzf
# ---------
if [[ ! "$PATH" == */home/billy/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/billy/.fzf/bin"
fi

source <(fzf --zsh)
