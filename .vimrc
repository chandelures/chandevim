" Basic setting {
    " Platform {
        silent function! OSX()
            return has('macunix')
        endfunction
        silent function! LINUX()
            return has('unix') && !has('macunix') && !has('win32unix')
        endfunction
        silent function! WINDOWS()
            return (has('win32') || has('win64'))
        endfunction
    " }
    
    " Basics {
        " 设置不兼容vi模式
        set nocompatible
   		" 让vimrc配置立刻生效
    	autocmd BufWritePost $MYVIMRC source $MYVIMRC
        if !WINDOWS()
            set shell=/bin/sh
        endif
    " }


    " Use before config file {
        if filereadable(expand("~/.vimrc.before"))
            source ~/.vimrc.before
        endif
    " }

    " Use plugs config file {
        if filereadable(expand("~/.vimrc.plugs"))
            source ~/.vimrc.plugs
        endif
    " }
" }


" General {
    " 不兼容vi模式
    set nocompatible
    " 菜单设置
    set langmenu=zh_CN.UTF-8
    if v:version >= 603
        set helplang=cn
    endif
	" 鼠标可用
	set mouse=a
    set selection=exclusive
    set selectmode=mouse,key
	" 文件自动检测外部更改
	set autoread
	" 显示输入的命令
	set showcmd
    " 读取文件类型
    filetype plugin indent on
    " 编码类型
    set encoding=utf-8
    set fileencoding=utf-8
    scriptencoding utf-8
    " 设置历史记录数量
    set history=1000
    " 关闭拼写检查
    set nospell
    " 关闭声音
    set noeb
    set vb
    " 设置粘贴模式
    set paste
	" 设置备份
	set backup
    " 自动跳转到上次修改的位置
    if has("autocmd")
      au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    endif
" }

" Vim UI {
	" 语法高亮
	syntax on
    syntax enable
    " 背景色
    set background=dark
	" 颜色方案
	if filereadable(expand("~/.vim/plugged/vim-colors-solarized/colors/solarized.vim"))
        let g:solarized_termcolors=256
        let g:solarized_tertrans=1
        let g:solarized_contrast="normal"	
        let g:solarized_visibility="normal"
        colorscheme solarized
	endif
	" 显示行号
	set number
	" 设置标尺
	set ruler
    " 设置屏幕大小
    set lines=40
    set columns=100
    " 设置行间距
    set linespace=0
	" 不要闪烁
	set novisualbell
    " 搜索设置
    set ignorecase
	set hlsearch
    " 显示括号匹配
    set showmatch
	" 启动显示状态行
	set laststatus=2
" }

" Formatting {
	" 折叠设置
    set foldenable
    " 拆行设置
    set nowrap
	" c文件自动缩进
	set cindent
	" 自动缩进
	set autoindent
	" 智能缩进
	set smartindent
	" 窗口设置
	set splitright
	set splitbelow
	" tab缩进设置
	set expandtab
	set tabstop=4
	set shiftwidth=4
    set softtabstop=4
	set smarttab

	" 高级缩进设置
	autocmd FileType haskell,puppet,ruby,yml setlocal expandtab shiftwidth=2 softtabstop=2
    
" }

" Mappings {
    let mapleader = ','
    let maplocalleader = "_"

    " 设置跳行
    noremap j gj
    noremap k gk
    
    " 快速折叠
    nnoremap <silent> <leader>q gwip

    " 快速进行文件保存、退出
    nnoremap w!! w !sudo tee % >/dev/null

    " 快速插入指定字符
    noremap <leader>" viw<esc>i"<esc>hbi"<esc>lel
    noremap <leader>$ viw<esc>i$<esc>hbi$<esc>lel
    noremap <leader>' viw<esc>i'<esc>hbi'<esc>lel
    noremap <leader>` viw<esc>i`<esc>hbi`<esc>lel
" }

" Plugins {

    " NerdTree {
    if isdirectory(expand("~/.vim/plugged/nerdtree"))
            noremap <leader>n :NERDTreeToggle<CR>
            let NERDTreeShowBookmarks=1
            let NERDTreeIgnore=['\~$', '\.swo$', '\.swp', '\.git']
            let NERDTreechDirMode=0
            let NERDTreeQuitOnOpen=1
            let NERDTreeMouseMode=2
            let NERDTreeShowHidden=1
            let NERDTreeKeepTreeInNewTab=1
    endif
    " }

    " TagBar {
        if isdirectory(expand("~/.vim/plugged/nerdtree"))
            nnoremap <silent> <leader>tt :TagbarToggle<CR>
        endif
    " }
    
    " Vim-airline {
        if isdirectory(expand("~/.vim/plugged/vim-airline-themes"))
            let g:airline_theme='solarized'
            let g:airline_left_sep='›'
            let g:airline_right_sep='‹'
        endif

    " }

    " YouCompleteMe {
        if isdirectory(expand("~/.vim/plugged/YouCompleteMe"))

            let g:acp_enableAtStartup = 0
            let g:ycm_collect_identifiers_from_tags_files = 1

            let g:UltiSnipsExpandTrigger = '<C-j>'
            let g:UltiSnipsJumpForwardTrigger = '<C-j>'
            let g:UltiSnipsJumpBackwardTrigger = '<C-k>'            
            
            set completeopt-=preview
        endif
    " }
    
    " Syntastic {
        let g:syntastic_error_symbol='✗'
        let g:syntastic_warning_symbol='⚠'
        let g:syntastic_check_on_open=0
        let g:syntastic_check_on_wq=1
    " }

    " Python-mode {
        if !has('python') && !has('python3')
            let g:pymode = 0
        endif

        if isdirectory(expand("~/.vim/plugged/python-mode"))
            let g:pymode_trim_whitespaces = 0
            let g:pymode_options = 0
            let g:pymode_rope = 0
        endif
    " }

    " Rainbow {
        if isdirectory(expand("~/.vim/plugged/rainbow/"))
            let g:rainbow_active = 1
        endif
    " }

    " UndoTree {
        if isdirectory(expand("~/.vim/plugged/undotree"))
            nnoremap <leader>u :UndotreeToggle<CR>
            let g:undotree_SetFocusWhenToggle=1
        endif
    " }

    " Ctrlp {
        if isdirectory(expand("~/.vim/plugged/ctrlp.vim"))
            let g:ctrlp_working_path_mode = 'ra'
            let g:ctrlp_custom_ignore = {
                \ 'dir': '\.git$\|\.hg$\|\.svn$',
                \ 'file': '\.exe$\|\.so$\|\.dll$\|\.pyc$'
          \ }
        endif
    " }

    " Auto-pairs {
        let g:AutoPairs = {'(':')', '[':']', '{':'}', '`':'`'}
         
    " }
" }

" Basic Function {
    
" }

