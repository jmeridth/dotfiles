let g:mapleader = ','
let g:neovim2_venv=expand('~/.pyenv/versions/neovim2/bin/python')
let g:neovim3_venv=expand('~/.pyenv/versions/neovim3/bin/python')
let g:plugins_location=expand('~/.config/nvim/plugged')
let g:vimrc_location=expand('~/.vimrc')
let g:nvim_autoload_location=expand('~/.config/nvim/autoload/plug.vim')

augroup vimrc
    autocmd!
augroup END

if !empty(glob(g:neovim2_venv))
    let g:python_host_prog=g:neovim2_venv
endif

if !empty(glob(g:neovim3_venv))
    let g:python3_host_prog=g:neovim3_venv
endif

if empty(g:nvim_autoload_location)
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source g:vimrc_location
endif

" Plugins {
    call plug#begin(g:plugins_location)
    Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
    Plug 'ctrlpvim/ctrlp.vim'
    Plug 'rking/ag.vim'
    Plug 'scrooloose/syntastic'
    Plug 'scrooloose/nerdcommenter'
    Plug 'luochen1990/rainbow'
    Plug 'ervandew/supertab'
    Plug 'editorconfig/editorconfig-vim'
    Plug 'tpope/vim-fugitive'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'flazz/vim-colorschemes'
    Plug 'altercation/vim-colors-solarized'
    Plug 'edkolev/tmuxline.vim'
    Plug 'godlygeek/tabular'
    Plug 'nathanaelkane/vim-indent-guides'
    Plug 'majutsushi/tagbar'
    " setting vim specific autocomplete
    if has('nvim')
        Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    else
        Plug 'tpope/vim-sensible'
        Plug 'Shoouo/neocomplete.vim'
    endif

    " Python specific {
        Plug 'klen/python-mode', {'for': 'python'}
        Plug 'davidhalter/jedi-vim', {'for': 'python'}
        Plug 'zchee/deoplete-jedi', {'for': 'python'}
    " }

    " Ruby specific {
        Plug 'vim-ruby/vim-ruby', {'for': 'ruby'}
        Plug 'davidhalter/jedi-vim', {'for': 'python'}
    " }

    " Go specific {
        Plug 'fatih/vim-go', {'for': 'go'}
        let editor_name='vim'
        if has('nvim')
          let editor_name='nvim'
        endif
        let gocode_script=g:plugins_location . '/gocode/'. editor_name .'/symlink.sh'
        Plug 'nsf/gocode', {'for': 'go', 'rtp': editor_name, 'do': gocode_script } " Go autocompletion
        Plug 'godoctor/godoctor.vim', {'for': 'go'} " Gocode refactoring tool
    " }

    " Jinja specific {
        Plug 'mitsuhiko/vim-jinja', {'for': 'jinja'}
    " }

    " Markdown specific {
        Plug 'plasticboy/vim-markdown', {'for': 'markdown'}
    " }

    " Javascript specific {
        Plug 'pangloss/vim-javascript', {'for': 'js'}
        Plug 'walm/jshint.vim', {'for': 'js'}
    " }

    " Coffeescript specific {
        Plug 'kchmck/vim-coffee-script', {'for': 'coffeescript'}
    " }

    call plug#end()

    " deoplete / neocomplete {
    if has('nvim')
        let g:deoplete#enable_at_startup = 1
        let g:deoplete#enable_smart_case = 2
    else
        let g:neocomplete#enable_at_startup = 1
        let g:neocomplete#enable_smart_case = 2
    endif
    " }

    " synctasic {
        let g:syntastic_always_populate_loc_list = 1
        let g:syntastic_auto_loc_list = 1
        let g:syntastic_check_on_open = 0
        let g:syntastic_check_on_wq = 0
        "" Syntastic ruby
        let g:syntastic_ruby_checkers=['rubocop', 'rubylint']
        let g:syntastic_ruby_rubocop_exec='~/.rubocop.sh'
        "" CoffeeScript ruby
        let g:syntastic_coffee_checkers=['coffee', 'coffeelint']
        let g:syntastic_coffee_coffeelint_args = "-f ~/.coffeelint"
        "" Syntastic yaml
        let g:syntastic_yaml_checkers=['jsyaml']
        "" Syntastic javascript
        let g:Syntastic_javascript_checkers = ['eslint', 'jshint']
        "" Syntastic python
        let g:syntastic_python_checkers=['pylint']
        autocmd FileType python let g:syntastic_check_on_wq = 0
        set statusline+=%#warningmsg#
        set statusline+=%{SyntasticStatuslineFlag()}
        set statusline+=%*
    " }

      " nerdcommenter {
        let NERDDefaultAlign = 'left'
    " }

      " python-mode {
        let g:pymode_rope = 0
        let g:pymode_doc = 1
        let g:pymode_doc_key = 'K'
        let g:pymode_lint = 1
        let g:pymode_lint_checker = "pylint"
        let g:pymode_lint_write = 1
        let g:pymode_virtualenv = 0
        let g:pymode_breakpoint = 1
        let g:pymode_breakpoint_bind = '<leader>b'
        let g:pymode_syntax = 1
        let g:pymode_syntax_all = 1
        let g:pymode_syntax_indent_errors = g:pymode_syntax_all
        let g:pymode_syntax_space_errors = g:pymode_syntax_all
        let g:pymode_folding = 0
    " }

    " nerdtree {
        "" NERDTree
        map <C-e> :NERDTreeToggle<CR>
        map <Leader>e :NERDTreeFind<CR>
        map <Leader>nt :NERDTreeFind<CR>
        let NERDTreeShowBookmarks=1
        let NERDTreeQuitOnOpen=1
        let NERDTreeMinimalUI=1
        let NERDTreeShowHidden=1
        let NERDTreeDirArrows=1
        let NERDTreeAutoDeleteBuffer=1
        autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
    " }

    " ctrlp {
        let g:ctrlp_custom_ignore = 'vendor/ruby/\|node_modules/\|tmp/|coverage/'
        map <Leader>b :CtrlPBuffer<CR>
        map <Leader>m :CtrlPMRU<CR>
    " }

    " vim-indent-guides {
        let g:indent_guides_start_level = 2
        let g:indent_guides_guide_size = 1
        let g:indent_guides_enable_on_vim_startup = 1
    " }

    " airline {
        let g:airline_theme = "wombat"
        let g:airline_powerline_fonts = 1
    " }

    " tmuxline {
        let g:tmuxline_theme = "wombat"
    " }

    " git fugitive {
        let g:has_fugitive=1
    " }

    " Rainbow parens {
        let g:rainbow_active = 1
    " }

    " Jedi Vim {
        autocmd vimrc FileType python setlocal completeopt-=preview
        let g:jedi#use_splits_not_buffers = "right"
        let g:jedi#completions_enabled = '0'
        let g:jedi#show_call_signatures = '0'
    " }

    " tagbar {
        map <Leader>tb :TagbarToggle<CR>
        let g:tagbar_type_go = {
    	\ 'ctagstype' : 'go',
    	\ 'kinds'     : [
    		\ 'p:package',
    		\ 'i:imports:1',
    		\ 'c:constants',
    		\ 'v:variables',
    		\ 't:types',
    		\ 'n:interfaces',
    		\ 'w:fields',
    		\ 'e:embedded',
    		\ 'm:methods',
    		\ 'r:constructor',
    		\ 'f:functions'
    	\ ],
    	\ 'sro' : '.',
    	\ 'kind2scope' : {
    		\ 't' : 'ctype',
    		\ 'n' : 'ntype'
    	\ },
    	\ 'scope2kind' : {
    		\ 'ctype' : 't',
    		\ 'ntype' : 'n'
    	\ },
    	\ 'ctagsbin'  : 'gotags',
    	\ 'ctagsargs' : '-sort -silent'
        \ }
    " }
" }

" General {
    " Allow a trigger for the background
    set background=dark " Dark backgrounds cause we're emo
    function! ToggleBG()
        let s:tbg = &background
        " Inversion
        if s:tbg ==# 'dark'
            :echo "DARK"
            set background=light
        else
            :echo "LIGHT"
            set background=dark
        endif
    endfunction
    nnoremap <Leader>bg :call ToggleBG()<CR>

    filetype indent plugin on " Automatically detect file types
    syntax on
    set mouse=a
    set mousehide
    set encoding=utf8
    scriptencoding utf-8

    if $TMUX == ''
      set clipboard+=unnamed
    endif
    set viewoptions=folds,options,cursor,unix,slash
    set virtualedit=onemore
    set history=1000
    set nospell
    set hidden

    " Set it to the first line when editing a git commit message
    augroup gcommit
        au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])
    augroup END

    " Restore cursor to file position in previous editing session
    function! ResCur()
    if line("'\"") <= line("$")
        silent! normal! g`"
        return 1
    endif
    endfunction


    augroup resCur
        autocmd!
        autocmd BufWinEnter * call ResCur()
    augroup END

    " Sets central temp file location, to prevent local default behavior.
    if isdirectory($HOME . '/.vim/.tmp') == 0
        :silent !mkdir -m 700 -p ~/.vim/.tmp > /dev/null 2>&1
    endif

    set backupdir=~/.vim/.tmp ",~/.local/tmp/vim,/var/tmp,/tmp,
    set directory=~/.vim/.tmp ",~/.local/tmp/vim,/var/tmp,/tmp,

    if exists('+undofile')
        " undofile -- This allows you to use undos after exiting and
        "             restarting. NOTE: only present in 7.3+
        "             :help undo-persistence
        if isdirectory( $HOME . '/.vim/.undo' ) == 0
            :silent !mkdir -m 700 -p ~/.vim/.undo > /dev/null 2>&1
        endif
        set undodir=~/.vim/.undo
        set undofile
    endif
" }

" UI Options {
    au FocusLost,TabLeave * call feedkeys("\<C-\>\<C-n>")
    if has('gui_running')
        set guioptions-=r
        set guioptions-=l
        set guioptions-=R
        set guioptions-=L
    endif
    if has("nvim")
        " True color support
        set termguicolors
    endif
    silent! colorscheme vividchalk

    set splitbelow
    set splitright
    set tabpagemax=15   " Only show 15 tabs
    set showmode        " Display the current mode
    if exists('&inccommand')
        set inccommand=split " Turn on live preview substitute
    endif

    highlight clear SignColumn
    highlight clear LineNr
    " Enable transparency
    highlight Normal ctermbg=none
    highlight NonText ctermbg=none

    if has('cmdline_info')
        set ruler
        set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)
        set showcmd
    endif

    if has('statusline')
        set laststatus=2
        set statusline=%<%f\                    " Filename
        set statusline+=%w%h%m%r                " Options
        if g:has_fugitive == 1
            set statusline+=%{fugitive#statusline()}
        endif
        set statusline+=\ [%{&ff}/%Y]           " Filetype
        set statusline+=\ [%{getcwd()}]         " Current dir
        set statusline+=%=%-14.(%l,%cV%)\ %p%%  " Right aligned file nav info
    endif

    set backspace=indent,eol,start                  " Working backspace
    set number                                      " Line numbers are on
    set showmatch                                   " Show matching brackets/parenthesis
    set incsearch                                   " Find as you type search
    set ignorecase                                  " Case insensitive search
    set smartcase                                   " Case sensitive when uc present
    set wildmenu                                    " Show a list of completions for commands
    set wildmode=list:longest,full                  " Command <Tab> completion, list matches,then longest part, then all.
    set whichwrap=b,s,h,l,<,>,[,]                   " Backspace and cursor keys wrap too
    set scrolljump=5                                " Lines to scroll when cursor leaves screen
    set scrolloff=3                                 " Minimum lines to keep above/below cursor
    set list
    set listchars=tab:›\ ,trail:•,extends:#,nbsp:.  " Highlight problematic whitespace
    set nofoldenable
    " set foldmethod=indent
    " set foldlevelstart=99
    autocmd vimrc FileType python let &colorcolumn=80
    " Disable the annoying bells
    set noerrorbells visualbell t_vb=
    if has('autocmd')
        autocmd vimrc GUIEnter * set visualbell t_vb=
    endif
" }

" Formatting {
    set nowrap
    set autoindent
    set shiftwidth=4
    set expandtab
    set smarttab
    set tabstop=4
    set nojoinspaces
    function! StripTrailingWhitespace()
    let l:_s=@/
        let l:l = line('.')
        let l:c = line('.')
        %s/\s\+$//e
        let @/=l:_s
        call cursor(l:l, l:c)
    endfunction
    nnoremap <Leader>sw :call StripTrailingWhitespace()<CR>
    autocmd vimrc FileType c,cpp,java,php,javascript,puppet,python,rust,twig,xml,yml,perl,sql autocmd BufWritePre <buffer> :call StripTrailingWhitespace()
    autocmd vimrc Filetype haskell,puppet,ruby,yml,eruby,coffee,html setlocal ts=2 sts=2 sw=2
    autocmd vimrc Filetype javascript,vimrc setlocal ts=4 sts=4 sw=4
    autocmd vimrc Filetype python setlocal ts=4 sts=4 sw=4 colorcolumn=80
    autocmd vimrc FileType make setlocal noexpandtab
" }

" Key Mappings {
    map <c-j> <c-w>j " move up
    map <c-k> <c-w>k " move down
    map <c-l> <c-w>l " move left
    map <c-h> <c-w>h " move right

    ""Vertical split then hop to new buffer
    :noremap <Leader>v <c-w>v<cr>
    :noremap <Leader>h <c-w>s<cr>
    :noremap <Leader>V <c-w>t<c-w>H<cr>
    :noremap <Leader>H <c-w>t<c-w>K<cr>

    ""reset split
    :noremap <Leader>= <c-w>=<cr>
" }
