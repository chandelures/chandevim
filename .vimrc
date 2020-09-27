" Basic Config {
    " 设置vim不兼容vi模式
    set nocompatible
    " 设置默认shell
    set shell=/bin/sh
" }

" Plugins Setup {
    call plug#begin('~/.vim/plugged')
    " General {
        Plug 'scrooloose/nerdtree'
        Plug 'jiangmiao/auto-pairs'
        Plug 'rafi/awesome-vim-colorschemes'
        Plug 'vim-airline/vim-airline'
        Plug 'vim-airline/vim-airline-themes'
    " }

    " AutoComplete {}
        Plug 'neoclide/coc.nvim', {'branch': 'release'}
    " }

    " Snippet {
        " Plug 'SirVer/ultisnips'
        " Plug 'honza/vim-snippets'
    " }

    " AutoFormat {
        Plug 'Chiel92/vim-autoformat', {'branch': 'master', 'do': 'pip install pynvim'}
    " }

    " Vimtex {
        Plug 'lervag/vimtex'
    " }

    " Search {
        " Plug 'Yggdroot/LeaderF', { 'do': './install.sh' }
    " }
    call plug#end()
" }

" General Config {
    " 设置语言
    set langmenu=zh_CN.UTF-8

    " 设置鼠标
    set mouse=a
    set selection=exclusive
    set selectmode=mouse,key

    " 检测文件外部更改
    set autoread

    " 加快响应速度
    set updatetime=300

    " 显示输入的命令
    set showcmd

    " 加载vim自带插件相应的语法和脚本
    filetype plugin indent on

    " 编码
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

    " 设置配色方案
    if $COLORTERM=='truecolor'
        set termguicolors
    else
        set term=xterm
        set t_Co=256
    endif

    " 显示行号
    set number

    " 显示标尺
    set ruler

    " 设置行间距
    set linespace=0

    " 禁止闪烁
    set novisualbell

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

    " 缩进设置
    set cindent
    set autoindent
    set smartindent

    " 窗口设置
    set splitright
    set splitbelow

    " tab设置
    set expandtab
    set tabstop=4
    set shiftwidth=4
    set softtabstop=4
    set smarttab
" }

" Mappings {
    let mapleader = ','

    " 快速进行文件保存、退出
    nnoremap w!! w !sudo tee % >/dev/null
" }

" Plugins Config{
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

    " Vim-colors-solarized {
        if isdirectory(expand("~/.vim/plugged/awesome-vim-colorschemes"))
            let g:solarized_termtrans=1
            colorscheme solarized8
        endif
    " }

    " Vim-airline {
        if isdirectory(expand("~/.vim/plugged/vim-airline-themes"))
            let g:airline_theme='solarized'
            let g:airline_left_sep='›'
            let g:airline_right_sep='‹'
        endif
    " }

    " Coc.nvim {
        if isdirectory(expand("~/.vim/plugged/coc.nvim"))
            " 映射Tab触发自动补全
            inoremap <silent><expr> <TAB>
                \ pumvisible() ? "\<C-n>" :
                \ <SID>check_back_space() ? "\<TAB>" :
                \ coc#refresh()
            inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

            function! s:check_back_space() abort
                let col = col('.') - 1
                return !col || getline('.')[col - 1]  =~# '\s'
            endfunction

            " 映射enter选择补全
            if exists('*complete_info')
                inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
            else
                inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
            endif
        endif
    " }

    " Vimtex {
        if isdirectory(expand("~/.vim/plugged/vim-autoformat"))
            let g:tex_flavor = 'latex'
            let g:vimtex_view_general_viewer = 'okular'
            " let g:vimtex_compliler_progname = 'xelatex'

            let g:vimtex_compiler_latexmk = {
                \ 'build_dir' : '',
                \ 'callback' : 1,
                \ 'continuous' : 1,
                \ 'executable' : 'latexmk',
                \ 'hooks' : [],
                \ 'options' : [
                \   '-xelatex',
                \   '-synctex=1',
                \   '-interaction=nonstopmode',
                \]
            \}
        endif
    " }

    " Auto-format {
        if isdirectory(expand("~/.vim/plugged/vim-autoformat"))
            noremap <leader>a :Autoformat<CR>
            auto BufWrite * :Autoformat
            autocmd filetype vim,tex let b:autoformat_autoindent=0
        endif
    " }
" }
