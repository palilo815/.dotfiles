# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"


#############
# oh my zsh #
#############

plugins=(git alias-tips zsh-autosuggestions zsh-syntax-highlighting)

export ZSH_PLUGINS_ALIAS_TIPS_EXCLUDES="_"

source $ZSH/oh-my-zsh.sh


######################
# user configuration #
######################

export ARCHFLAGS="-arch x86_64"
export EDITOR="nvim"

# Install Ruby Gems to ~/gems
# export GEM_HOME="$HOME/gems"
# export PATH="$HOME/gems/bin:$PATH"
# export PATH="$HOME/.local/share/gem/ruby/3.0.0/bin:$PATH"  # PATH for ruby
export PATH="$HOME/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin:$PATH"

eval "$(zoxide init zsh)"

alias vim="nvim"
alias ls="exa -al --color=always --group-directories-first"
alias la="exa -a --color=always --group-directories-first"
alias ll="exa -l --color=always --group-directories-first"
alias lt="exa -aT --color=always --group-directories-first"
alias ld="exa -lD --color=always"
alias l.="exa -a | rg '^\.'"
alias shut="sudo shutdown now"
alias restart="sudo reboot now"


####################
# from zsh-newuser #
####################

# HISTFILE=~/.histfile
# HISTSIZE=1000
# SAVEHIST=1000

setopt autocd beep nomatch

# bindkey -v

zstyle :compinstall filename "/home/palilo/.zshrc"

autoload -Uz compinit
compinit

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
