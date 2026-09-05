# Personal aliases.
#
# oh-my-zsh sources $ZSH_CUSTOM/*.zsh after it loads plugins, so anything here
# would win over a plugin alias of the same name. Nothing here does that on
# purpose: the git plugin's aliases are left alone, and only names it doesn't
# already use are defined below. Run `alias` for the full list.

alias cl='clear'

# Re-exec the shell to pick up config changes without opening a new tab.
alias reload='exec zsh'

# ~/.zshrc is a symlink into this repo, so an edit here lands in git.
alias zshrc='${EDITOR:-vi} ~/.zshrc'

# Readable $PATH, one entry per line. Worth having: a Node that is on the PATH
# interactively but missing from non-interactive shells is a confusing failure.
alias path='print -l $path'

# Reveal the current directory in Finder.
alias o='open .'

# What is listening, and on which port. -n and -P skip DNS and service-name
# lookups, which is the difference between instant and a few seconds.
alias ports='lsof -iTCP -sTCP:LISTEN -n -P'

# Public IP as seen from outside, not the LAN address ifconfig reports.
alias myip='curl -s https://ifconfig.me'

# Biggest things in the current directory first. sort -h reads the human-
# readable sizes du prints, so 2G sorts above 900M rather than below it.
alias dus='du -sh -- * | sort -h'

# Re-run the config in this shell, keeping variables and functions you set
# interactively. `reload` re-execs instead, which is the cleaner reset when
# something is genuinely stuck.
alias src='source ~/.zshrc'
