#!/bin/bash

## params
app_name="chandevim"

APP_PATH=`pwd`

REPO_URL="https://github.com/chandelures/chandevim.git"

VIM_PLUG_INSTALL_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
VIM_PLUG_DIR="$HOME/.vim/autoload"

VIMRC_URL="https://raw.githubusercontent.com/chandelures/chandevim/master/vimrc"
VIMRC_PLUGIN_URL="https://raw.githubusercontent.com/chandelures/chandevim/master/vimrc.plugin"

VIM_DIR="$HOME/.vim"

COC_PLUGINS="coc-snippets"

## basic function
msg() {
    printf '[info] %b\n' "$1" >&2
}

## tools
backup() {
    local backup_files=("#@")

    for backup_file in $backup_files;
    do
        [ -e "$backup_file" ] && [ ! -L "$backup_file" ] && mv -v "$backup_file" "${backup_file}.bak";
    done
}

download_vimrc() {
    local flag=$1 || ""
    curl $flag -fLo "$VIM_DIR/vimrc" "$VIMRC_URL"
    curl $flag -fLo "$VIM_DIR/vimrc.plugin" "$VIMRC_PLUGIN_URL"

    if [ $? -ne 0 ]; then
        msg "Download vim config file Failed."
        exit 1
    fi

    msg "Download vim config file successful."
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

    if [ $? -ne 0 ]; then
        msg "Update plugins Failed!"
        exit 1
    fi

    msg "Update plugins Successful!"
}

install_coc_plug() {
    local plugs="$COC_PLUGINS"
    local shell="$SHELL"

    export SHELL='/bin/sh'

    vim \
        "+CocInstall $plugs" \
        "+qall"

    export SHELL='$shell'

    if [ $? -ne 0 ]; then
        msg "Install coc plugins Failed!"
        exit 1
    fi

    msg "Install coc plugins Successful!"
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

    download_vimrc "$proxy_flag"

    install_plug

    install_coc_plug

    msg "Done."
}

## update
update() {
    local proxy_flag=$1 || ""

    if program_not_exists 'vim'; then
        msg "You don't have vim."
        return
    fi

    if program_not_exists 'curl'; then
        msg "You don't have curl."
        return
    fi

    download_vimrc "$proxy_flag"

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
            h)
                usage
                exit 0
                ;;
            i)
                install "$proxy_flag"
                exit 0
                ;;
            u)
                update "$proxy_flag"
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
