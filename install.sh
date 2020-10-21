#!/bin/bash

## params
app_name="chandevim"
APP_PATH=`pwd`
REPO_URL="https://github.com/chandelures/chandevim.git"
VIM_PLUG_URL="https://github.com/junegunn/vim-plug"
VIM_PLUG_NAME="vim-plug"
VIM_PLUG_DIR="$HOME/.vim/autoload/"

## basic function
msg() {
    printf '%b\n' "$1" >&2
}

## tools
backup() {
    local backup_files=("#@")
    for backup_file in $backup_files;
    do
        [ -e "$backup_file" ] && [ ! -L "$backup_file" ] && mv -v "$backup_file" "${backup_file}.bak";
    done
}

create_symlinks() {
    local source_path="$1"
    local target_path="$2"

    ln -sf "$source_path/.vimrc" "$target_path/.vimrc"
    ln -sf "$source_path/.vimrc.plugin" "$target_path/.vimrc"
}

program_not_exists() {
    local ret='0'

    command -v $1 > /dev/null 2>&1 || { local ret='1'; }
    if [ "$ret" -ne 0 ]; then
        return 0
    fi

    return 1
}

install_plug_mgr() {
    local plug_mgr_name=$1
    local plug_mgr_dir=$2
    local plug_mgr_url=$3

    if [ ! -e "$plug_mgr_name" ]; then
        git clone $plug_mgr_url
    fi

    if [ -e "$plug_mgr_dir" ]; then
        cp "$APP_PATH/vim-plug/plug.vim" "$plug_mgr_dir"
    else
        mkdir -p "$plug_mgr_dir"
        cp "$APP_PATH/vim-plug/plug.vim" "$plug_mgr_dir"
    fi

    rm -rf $plug_mgr_name
}

install_plug() {
    local shell="$SHELL"
    export SHELL='/bin/sh'

    vim \
        "+PlugInstall" \
        "+PlugClean" \
        "+qall"

    export SHELL="$shell"
}

update_plug() {
    local shell="$SHELL"
    export SHELL='/bin/sh'

    vim \
        "+PlugUpdate" \
        "+PlugClean" \
        "+qall"

    export SHELL="$shell"
}

## install
install() {
    if program_not_exists 'curl'; then
        msg "You don't have curl."
    fi

    if program_not_exists 'vim'; then
        msg "You don't have vim."
    fi

    if program_not_exists 'git'; then
        msg "You don't have git."
    fi

    backup "$HOME/.vimrc" \
        "$HOME/.vimrc.plugin" \
        "$HOME/.vim"

    create_symlinks "$APP_PATH" \
        "$HOME"

    install_plug_mgr "$VIM_PLUG_NAME" \
        "$VIM_PLUG_DIR" \
        "$VIM_PLUG_URL"

    install_plug
}

## update
update() {
    if program_not_exists 'vim'; then
        msg "You don't have vim."
    fi

    if program_not_exists 'git'; then
        msg "You don't have git."
    fi

    git pull
    update_plug
}

## remove
remove() {
    read -r -p "Do you really want to remove the $app_name? [Y/n]" input

    case $input in
        [yY][eR][sS]|[yY])
            rm -f $HOME/.vimrc
            rm -f $HOME/.vimrc.plugin
            rm -rf $HOME/.vim
            exit 0
            ;;
        [nN][oO]|[nN])
            msg "Canceled"
            exit 0
            ;;
        *)
            msg "Invalid input"
            exit 1
            ;;
    esac
}

## main
main(){
    local OPTIND
    local OPTARG
    while getopts iur-: OPT;
    do
        case $OPT in
            -)
                case $OPTARG in
                    install)
                        install
                        exit 0
                        ;;
                    update)
                        upgrade
                        exit 0
                        ;;
                    remove)
                        remove
                        exit 0
                        ;;

                    \?)
                        exit 1
                        ;;
                esac
                ;;
            i)
                install
                exit 0
                ;;
            u)
                update
                exit 0
                ;;
            r)
                remove
                exit 0
                ;;
            \?)
                exit 1
                ;;
        esac
    done
    install
}

main $@
