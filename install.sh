#!/bin/bash

## params
app_name="chandevim"

REPO_URL="https://github.com/chandelures/chandevim.git"

VIM_PLUG_INSTALL_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
VIM_PLUG_DIR="$HOME/.vim/autoload"

VIMRC_URL="https://raw.githubusercontent.com/chandelures/chandevim/master/vimrc"
VIMRC_PLUGIN_URL="https://raw.githubusercontent.com/chandelures/chandevim/master/vimrc.plugin"

VIM_DIR="$HOME/.vim"

COC_PLUGINS="coc-snippets"

CURL="curl"

## basic function
msg() {
    printf '[info] %b\n' "$1" >&2
}

err() {
    printf '[error] %b\n' "$1" >&2
}

## tools
backup() {
    local backup_files=("$@")

    for backup_file in $backup_files;
    do
        [ -e "$backup_file" ] && [ ! -L "$backup_file" ] && mv -v "$backup_file" "${backup_file}.bak";
    done
}

download_vimrc() {
    $CURL $flag -fLo "$VIM_DIR/vimrc" "$VIMRC_URL"
    $CURL $flag -fLo "$VIM_DIR/vimrc.plugin" "$VIMRC_PLUGIN_URL"

    process_check $? "Download vim config file"
}

program_not_exists() {
    local ret='0'

    command -v $1 > /dev/null 2>&1 || { local ret='1'; }
    if [ "$ret" -ne 0 ]; then
        return 0
    fi

    return 1
}

programs_check() {
    local programs=("$@")

    for program in $programs;
    do
        if program_not_exists $program; then
            err "You don't have $program."
            exit 1
        fi
    done
}

process_check() {
    local status=$1
    local process_name=$2

    if [ $1 -ne 0 ]; then
        err "$process_name Failed!"
        exit 1
    fi

    msg "$process_name Successful"
}

install_plug_mgr() {
    $CURL $flag -fLo "$VIM_PLUG_DIR/plug.vim" --create-dirs $VIM_PLUG_INSTALL_URL

    process_check $? "Install plug manager"
}

install_plug() {
    local shell="$SHELL"
    export SHELL='/bin/sh'

    vim \
        "+PlugInstall" \
        "+PlugClean" \
        "+qall"

    process_check $? "Install vim plugins"

    export SHELL="$shell"
}

update_plug() {
    local shell="$SHELL"
    export SHELL='/bin/sh'

    vim \
        "+PlugUpdate" \
        "+PlugClean" \
        "+qall"

    process_check $? "Update plugins"

    export SHELL="$shell"
}

install_coc_plug() {
    local plugs="$COC_PLUGINS"
    local shell="$SHELL"

    export SHELL='/bin/sh'

    vim \
        "+CocInstall $plugs" \
        "+qall"

    process_check $? "Install coc plugins"

    export SHELL='$shell'
}

update_coc_plug() {
    local shell="$SHELL"

    export SHELL='/bin/sh'

    vim \
        "+CocUpdate" \
        "+qall"
    
    process_check $? "Update coc plugins"

    export SHELL='$shell'
}

## install
install() {
    programs_check "vim" "curl"

    backup "$HOME/.vim"

    install_plug_mgr

    download_vimrc

    install_plug

    install_coc_plug

    msg "Done."
}

## update
update() {
    programs_check "vim" "curl"

    download_vimrc 

    update_plug

    update_coc_plug

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
    echo "USAGE:"
    echo "    ./install.sh [parameter]"
    echo "PARAMETER:"
    echo "    -i        Install the $app_name"
    echo "    -u        Update the $app_name"
    echo "    -r        Remove the $app_name"
    echo "    -h        Display this message"
    echo "    -p        Proxy setting"
    echo ""
    echo $REPO_URL
}

## main
main(){
    local OPTIND
    local OPTARG

    while getopts ihurp:-: OPT;
    do
        case $OPT in
            p)
                export CURL="curl -x $OPTARG"
                ;;
            h)
                usage
                exit 0
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
                usage
                exit 1
                ;;
        esac
    done
    install
}

main $@
