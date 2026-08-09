PROMPT=$'
%{$fg_bold[white]%}%n@%m %{$fg[white]%}%D{[%H:%M:%S]} %{$reset_color%}%{$fg[white]%}[%~]%{$reset_color%} $(git_prompt_info)\
%{$fg[white]%}->%{$fg_bold[white]%} %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[white]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{%F{120}%}*%{$fg[white]%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
