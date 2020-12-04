#!/bin/bash

## params
app_name="chandevim"
APP_PATH=`pwd`
REPO_URL="https://github.com/chandelures/chandevim.git"
VIM_PLUG_INSTALL_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
VIM_PLUG_DIR="$HOME/.vim/autoload"
VIM_DIR="$HOME/.vim"

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
    if [ ! -e "$HOME/.vim" ];then
        mkdir "$HOME/.vim"
    fi

    ln -sf "$APP_PATH/vimrc" "$VIM_DIR/vimrc"
    ln -sf "$APP_PATH/vimrc.custom" "$VIM_DIR/vimrc.custom"
    ln -sf "$APP_PATH/vimrc.plugin" "$VIM_DIR/vimrc.plugin"

    if [ $? -ne 0 ]; then
        msg "Create symbol links Failed!"
        exit 1
    fi

    msg "Create symbol links Successful!"
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
    local flag=$1 || ""

    curl $flag -fLo "$VIM_PLUG_DIR/plug.vim" --create-dirs $VIM_PLUG_INSTALL_URL

    if [ $? -ne 0 ]; then
        msg "Install plug manager Failed!"
        exit 1
    fi

    msg "Install plug manager Successful!"

}

install_plug() {
    local shell="$SHELL"
    export SHELL='/bin/sh'

    vim \
        "+PlugInstall" \
        "+PlugClean" \
        "+qall"

    if [ $? -ne 0 ]; then
        msg "Install plugins Failed!"
        exit 1
    fi

    msg "Install plugins Successful!"

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
    local proxy_flag=$1 || ""

    if program_not_exists 'curl'; then
        msg "You don't have curl."
        return
    fi

    if program_not_exists 'vim'; then
        msg "You don't have vim."
        return
    fi

    if program_not_exists 'git'; then
        msg "You don't have git."
        return
    fi

    backup "$HOME/.vim"

    install_plug_mgr "$proxy_flag"

    create_symlinks

    install_plug

    msg "Done."
}

## update
update() {
    if program_not_exists 'vim'; then
        msg "You don't have vim."
        return
    fi

    if program_not_exists 'git'; then
        msg "You don't have git."
        return
    fi

    git pull

    update_plug

    msg "Done."
}

## remove
remove() {
    read -r -p "Do you really want to remove the $app_name? [Y/n] " input

    case $input in
        [yY][eR][sS]|[yY])
            rm -rf $HOME/.vim
            msg "Done."
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

##
usage() {
    msg "USAGE:"
    msg "    ./install.sh [parameter]"
    msg "PARAMETER:"
    msg "    -i        Install the $app_name"
    msg "    -u        Update the $app_name"
    msg "    -r        Remove the $app_name"
    msg "    -h        Display this message"
    msg "    -p        Proxy setting"
    msg ""
    msg "https://github.com/chandelures/chandevim"
}

## main
main(){
    local OPTIND
    local OPTARG

    local proxy_flag=""

    while getopts ihurp:-: OPT;
    do
        case $OPT in
            p)
                proxy_flag="-x "$OPTARG
                ;;
        esac

        case $OPT in
            h)
                usage
                exit 0
                ;;
            i)
                install "$proxy_flag"
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
                usage
                exit 1
                ;;
        esac
    done
    install "$proxy_flag"
}

main $@
