
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# set PATH so it includes user's private bin if it exists
if [ -d ~/bin ] ; then
    PATH=~/bin:"${PATH}"
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

# 256 colors
export XTERM=xterm-256color

# dircolors
if [ -f ~/.dircolors ]; then
    eval `dircolors .dircolors`
fi

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# set the title
PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'

# some more ls aliases
if [ $(uname) = Darwin ]; then
    alias ls='ls -G'
else
    alias ls='ls --color'
fi
alias l='ls -lh'
alias ll='ls -lha'
alias la='ls -a'
alias lsize='ls -al | sort -n -r +4'
alias less='less -R'
alias df='df -h'
alias du='du -h'
alias vi='vim'

# STD VARS
export EDITOR="vim"
export PAGER="less"

# Python
export PIP_REQUIRE_VIRTUALENV=true
export PIP_DOWNLOAD_CACHE=$HOME/.pip_download_cache

# my host specific settings
if [ -f ~/.bash_local_rc ]; then
    source ~/.bash_local_rc
fi

