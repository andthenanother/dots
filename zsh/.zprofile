export ELECTRON_OZONE_PLATFORM_HINT=wayland
export GDK_BACKEND=wayland
export KRITA_USE_NATIVE_CANVAS_SURFACE=1
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt6ct
export _JAVA_AWT_WM_NONREPARENTING=1

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.local/share/zsh/history

export PATH="$XDG_CONFIG_HOME/scripts:$PATH"

export EDITOR=nvim
export VISUAL=nvim
export MANPAGER='nvim +Man!'

export ZK_NOTEBOOK_DIR="$HOME/notes"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc-2.0"
export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/ripgreprc"

export GNUPGHOME="$XDG_DATA_HOME/gnupg"

export GOPATH="$XDG_DATA_HOME/go"
export GOBIN="$GOPATH/bin"

export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
