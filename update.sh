#!/bin/bash
program_exists() {
    local ret='0'
    command -v $1 >/dev/null 2>&1 || { local ret='1'; }
    # fail on non-zero return value
    if [ "$ret" -ne 0 ]; then
        return 1
    fi
    return 0
}

msg() {
    printf '%b\n' "$1" >&2
}

if program_exists "vim"; then
    echo
    msg "Start update plugins for vim"
    vim +PlugUpdate +qall
fi

