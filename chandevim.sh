#!/bin/bash

## params
app_name="chandevim"
APP_PATH=`pwd`
[ -z $VIMRC ] && VIMRC="$HOME/.vimrc"
[ -z $VIMRCPLUGS ] && VIMRCPLUGS="$HOME/.vimrc.plugs"
[ -z $VIM_DIR ] && VIMDIR="$HOME/.vim"
[ -z $REPO_URL ] && REPO_URL="https://github.com/chandelures/chandevim.git"
[ -z $VIM_PLUG_URL ] && VIM_PLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
[ -z $VIM_PLUG_DIR ] && VIM_PLUG_DIR="$HOME/.vim/autoload/plug.vim"

## basic tools

msg() {
    printf '%b\n' "$1" >&2
}

success() {
    local success_message="$1"
    if [ "$ret" -eq 0 ]; then
        msg "[sucess] ${success_message}"
    fi
}

error() {
    local error_message="$1"
    msg "[error] ${error_message}"
}

program_exists() {
    local ret='0'
    command -v $1 >/dev/null 2>&1 || { local ret='1'; }
    if [ "$ret" -ne 0 ]; then
        return 1
    fi
    return 0
}

program_must_exist() {
    local program="$1"
    program_exists $program
    if [ "$?" -ne 0 ]; then
        error "You must have '$program' installed to continue."
    fi
}
## install functions
backup() {
    local backup_files=[$1, $2, $3]
    for backup_file in $backup_files;
    do
        [ -e "$backup_file" ] && [ ! -L "$backup_file" ] && mv -v "$backup_file" "${backup_file}.bak";
    done
    local ret="$?"
    success "Your original vim configruation has been backed up!"
}

ln_if_exit() {
    local source_path="$1"
    local target_path="$2"
    
    if [ -e "$source_path" ]; then
        ln -sf "$source_path" "$target_path"
    fi
    local ret="$?"
    success "The symlink between $source_path and $target_path has been create"
}

create_symlinks() {
    local source_path="$1"
    local target_path="$2"

    ln_if_exit "$source_path/.vimrc" "$target_path/.vimrc"
    ln_if_exit "$source_path/.vimrc.plugs" "$target_path/.vimrc"
    ln_if_exit "$source_path/.vim" "$target_path/.vimrc"

    local ret="$?"
    success "Setting up all vim symlinks."
}


set_plug_manager() {
    local vim_plug_dir=$1
    local vim_plug_url=$2
    curl -fLo  $vim_plug_dir --create-dirs $vim_plug_url
    local ret="$?"
    success "Vim-plug has been set up"
}
    
setup_plug(){
    local shell="$SHELL"
    export SHELL='/bin/sh'
    
    vim \
        "+PlugInstall" \
        "+PlugClean" \
        "+qall"
    
    export $SHELL="$shell"

    success "Now vim plugs has been set up"
}


## command functions

usage() {
    msg "USAGE: ./${app_name}.sh [-urh]"
    msg "\t-u     Update plugs for vim"
    msg "\t-r     Remove the chandevim"
    msg "\t-h     Display this message"
}

install(){
    program_must_exist "vim"
    program_must_exist "curl"
     
    backup "$HOME/.vim" \
           "$HOME/.vimrc" \
           "$HOME/.vim"

    create_symlinks "$APP_PATH" \
                    "$HOME"

    set_plug_manager "$VIM_PLUG_DIR"
                     "$VIM_PLUG_URL"

    setup_plug 
    
    msg "Done!"
    msg "\nThanks for installing $app_name."
    
}

remove() {
    read -r -p "Do you really want to remove the $app_name? [Y/n]" input
    
    case $input in
        [yY][eR][sS]|[yY])
            if test -e $VIMRC; then
                rm $VIMRC
            fi
            if test -e $VIMRCPLUGS; then
                rm $VIMRCPLUGS
            fi
            if test -e $VIM_DIR; then
                rm -rf $VIM_DIR
            fi
            msg "Thanks for using $app_name"
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

update() {
    if program_exists "vim"; then
        msg "Start update plugins for vim"
        vim \
            +PlugUpdate \
            +qall
    fi

    msg "Update the vim plugs successfully"
}


## main
function main(){
    local OPTIND
    while getopts iurh OPT;
    do
        case $OPT in
            i)
                install
                exit 0
                ;;

            u)
                update
                exit 0
                ;;

            h)
                usage
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
}

main $@
