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

plugins=(aliases alias-tips archlinux copyfile extract git zoxide zsh-autosuggestions zsh-syntax-highlighting)

fpath+="${ZSH_CUSTOM:-"$ZSH/custom"}/plugins/zsh-completions/src"

export ZSH_PLUGINS_ALIAS_TIPS_EXCLUDES="_"

source $ZSH/oh-my-zsh.sh

######################
# user configuration #
######################

setopt autocd beep nomatch

bindkey '^ ' autosuggest-accept

export ARCHFLAGS="-arch x86_64"
export EDITOR="nvim"

# Install Ruby Gems to ~/gems
# export GEM_HOME="$HOME/gems"
# export PATH="$HOME/gems/bin:$PATH"
# export PATH="$HOME/.local/share/gem/ruby/3.0.0/bin:$PATH"  # PATH for ruby
# export PATH="$HOME/.cargo/bin:$PATH"
# export PATH="$HOME/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin:$PATH"

alias vim="nvim"
alias ls="eza -al --colour=always --group-directories-first --icons=always"
alias ll="eza -l --colour=always --group-directories-first --icons=always"
alias lt="eza -aT --colour=always --group-directories-first --icons=always"
alias ld="eza -lD --colour=always --icons=always"
alias l.="eza -a | rg '^\.'"
alias lg="lazygit"
alias shut="sudo shutdown now"
alias restart="sudo reboot now"

####################
# from zsh-newuser #
####################

zstyle :compinstall filename "/home/palilo/.zshrc"

autoload -Uz compinit
compinit

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
