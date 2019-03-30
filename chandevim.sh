#!/bin/bash

## params
app_name="chandevim"
APP_PATH=`pwd`
[ -z $VIMRC ] && VIMRC="$HOME/.vimrc"
[ -z $VIMRCPLUGS ] && VIMRCPLUGS="$HOME/.vimrc.plugs"
[ -z $VIM_DIR ] && VIM_DIR="$HOME/.vim"
[ -z $REPO_URL ] && REPO_URL="https://github.com/chandelures/chandevim.git"
[ -z $VIM_PLUG_URL ] && VIM_PLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
[ -z $VIM_PLUG_DIR ] && VIM_PLUG_DIR="$HOME/.vim/autoload/plug.vim"

ret=0

## basic tools

msg() {
    printf '%b\n' "$1" >&2
}

success() {
    local success_message="$1"
    if [ "$ret" -eq 0 ]; then
        msg "\033[32m[sucess] ${success_message}\033[0m"
    fi
}

error() {
    local error_message="$1"
    msg "\033[31m[error] ${error_message}\033[0m"
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

ln_if_exit() {
    local source_path="$1"
    local target_path="$2"
    
    if [ -e "$source_path" ]; then
        ln -sf "$source_path" "$target_path"
    else
        error "Failed to create the symlink between $source_path and $target_path"
    fi
    ret="$?"
    success "The symlink between $source_path and $target_path has been create"
}

rm_if_exit() {
    local rm_file="$1"
    if [ -e "$rm_file" ]; then
        rm -rf "$rm_file"
    else
        msg "$rm_file is not exits"
    fi
    ret="$?"
    success "$rm_file has been deleted"
}

## install functions
backup() {
    local backup_files=($1 $2 $3)
    for backup_file in $backup_files;
    do
        [ -e "$backup_file" ] && [ ! -L "$backup_file" ] && mv -v "$backup_file" "${backup_file}.bak";
    done
    ret="$?"
    success "Your original vim configruation has been backed up!"
}

create_symlinks() {
    local source_path="$1"
    local target_path="$2"

    ln_if_exit "$source_path/.vimrc" "$target_path/.vimrc"
    ln_if_exit "$source_path/.vimrc.plugs" "$target_path/.vimrc.plugs"

    ret="$?"
    success "Setting up all vim symlinks."
}

set_plug_manager() {
    local vim_plug_dir=$1
    local vim_plug_url=$2
    curl -fLo $vim_plug_dir --create-dirs \
        $vim_plug_url
    ret="$?"
    success "Vim-plug has been set up"
}
    
setup_plug(){
    local shell="$SHELL"
    export SHELL='/bin/sh'
    
    vim \
        "+PlugInstall" \
        "+PlugClean" \
        "+qall"
    
    export SHELL="$shell"
    ret="$?"
    success "Now all vim plugs has been set up"
}

## command functions

usage() {
    msg "  USAGE:"
    msg "    ./${app_name}.sh [parameter]"
    msg "  PARAMETER:"
    msg "    -i  or  --install        Install the $app_name"
    msg "    -u  or  --update-plug    Update plugs for vim"
    msg "    -g  or  --upgrade        Upgrade the $app_name"
    msg "    -r  or  --remove         Remove the $app_name"
    msg "    -h  or  --help           Display this message"
}

install(){
    program_must_exist "vim"
    program_must_exist "curl"
     
    backup "$VIMRC" \
           "$VIMRCPLUGS" \
           "$VIM_DIR"

    create_symlinks "$APP_PATH" \
                    "$HOME"

    set_plug_manager "$VIM_PLUG_DIR" \
                     "$VIM_PLUG_URL"

    setup_plug 

    if [ "$ret" -eq 0 ]; then
        success "Done!"
        success "Thanks for installing $app_name."
    else
        error "Failed to install $app_name"
    fi
}

upgrade() {
    if program_exists "git"; then
        git pull
    else
        error "git is not installed in this system"
    fi
    local shell="$SHELL"
    export SHELL='/bin/sh'
    
    vim \
        "+PlugUpdate" \
        "+PlugClean" \
        "+qall"
    
    export SHELL="$shell"

    success "Upgrade repo successfully"

}

remove() {
    read -r -p "Do you really want to remove the $app_name? [Y/n]" input
    
    case $input in
        [yY][eR][sS]|[yY])
            rm_if_exit $VIMRC
            rm_if_exit $VIMRCPLUGS
            rm_if_exit $VIM_DIR
            echo
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
        msg "Start to update plugins for vim"
        vim \
            +PlugUpdate \
            +qall
    else
        error "vim is not installed in this system"
    fi

    msg "Update vim plugs successfully"
}


## main
function main(){
    local OPTIND
    local OPTARG
    while getopts iugrh-: OPT;
    do
        case $OPT in
            -)
                case $OPTARG in
                    help)
                        usage
                        exit 0
                        ;;

                    install)
                        install
                        exit 0
                        ;;

                    update)
                        update
                        exit 0
                        ;;

                    upgrade)
                        upgrade
                        exit 0
                        ;;
                    
                    remove)
                        remove
                        exit 0
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
            
            g)
                upgrade
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
