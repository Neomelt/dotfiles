# CLI tools (fzf, zoxide, eza, bat, yazi), sourced from ~/.zshrc before syntax
# highlighting. Each block is skipped when its tool is not installed.

# fzf: Ctrl+R history, Ctrl+T files, Alt+C cd into a subdirectory.
if (( $+commands[fzf] )); then
  export FZF_DEFAULT_OPTS="--height=45% --layout=reverse --border=rounded --info=inline-right \
--color=fg:#9aa4b5,fg+:#e8edf5,bg+:#1c2230,hl:#8fb8ff,hl+:#8fb8ff,info:#5d6676 \
--color=prompt:#8fb8ff,pointer:#8fb8ff,marker:#9ad89a,spinner:#8fb8ff,header:#5d6676,border:#2b3950"
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
  fi
  (( $+commands[bat] )) && export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:300 {}'"
  (( $+commands[eza] )) && export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons=always --color=always {}'"
  source <(fzf --zsh)
fi

# zoxide: `z 关键词` jumps to a directory you visit often, `zi` picks one with fzf.
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# eza: ls with icons and git status.
if (( $+commands[eza] )); then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -l --icons=auto --git --group-directories-first --time-style=relative'
  alias la='eza -la --icons=auto --git --group-directories-first --time-style=relative'
  alias lt='eza --tree --level=2 --icons=auto --group-directories-first'
fi

# bat: cat with syntax highlighting (`\cat` is the original), and coloured man pages.
if (( $+commands[bat] )); then
  export BAT_THEME="OneHalfDark"
  alias cat='bat -pp'
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"
fi

# yazi: `y` opens it and leaves the shell in the directory you quit from.
if (( $+commands[yazi] )); then
  y() {
    local tmp cwd
    tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
  }
fi

(( $+commands[lazygit] )) && alias lg='lazygit'
