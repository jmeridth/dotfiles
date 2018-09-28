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
    Plug 'mileszs/ack.vim'
    Plug 'ctrlpvim/ctrlp.vim'
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
    Plug 'junegunn/vim-easy-align'
    Plug 'majutsushi/tagbar'
    Plug 'JamshedVesuna/vim-markdown-preview'
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
        Plug 'tpope/vim-rails', {'for': 'ruby'}
        Plug 'tpope/vim-haml', {'for': 'ruby'}
        Plug 'tpope/vim-bundler', {'for': 'ruby'}
        Plug 'tpope/vim-rvm', {'for': 'ruby'}
        Plug 'Keithbsmiley/rspec.vim', {'for': 'ruby'}
    " }

    " Go specific {
        Plug 'fatih/vim-go', {'for': 'go'}
        let editor_name='vim'
        if has('nvim')
          let editor_name='nvim'
          Plug 'zchee/deoplete-go', { 'do': 'make'}
        endif
        Plug 'nsf/gocode', { 'rtp': 'vim', 'do': '~/.config/nvim/plugged/gocode/vim/symlink.sh' }
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
        Plug 'mxw/vim-jsx', {'for': 'js'}
        Plug 'walm/jshint.vim', {'for': 'js'}
    " }

    " Coffeescript specific {
        Plug 'kchmck/vim-coffee-script', {'for': 'coffee'}
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
    let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
    " }

    " go {
        let g:go_list_type = "quickfix"
        let g:go_highlight_functions = 1
        let g:go_highlight_methods = 1
        let g:go_highlight_structs = 1
        let g:go_highlight_interfaces = 1
        let g:go_highlight_operators = 1
        let g:go_highlight_build_constraints = 1
        let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
        autocmd FileType go nmap <leader>t  <Plug>(go-test)
        autocmd FileType go nmap <leader>b  <Plug>(go-build)
        autocmd FileType go nmap <leader>gc  <Plug>(go-callees)
        autocmd FileType go nmap <leader>gi  <Plug>(go-implements)
    " }

    " markdown {
        let g:vim_markdown_prewview_github = 1
        let g:vim_markdown_preview_browser='Google Chrome'
        let g:vim_markdown_preview_hotkey='<C-m>'
    " }

    " synctastic {
        let g:syntastic_always_populate_loc_list = 1
        let g:syntastic_auto_loc_list = 1
        let g:syntastic_check_on_open = 0
        let g:syntastic_check_on_wq = 0
        "" Syntastic ruby
        let g:syntastic_ruby_checkers=['rubocop', 'rubylint']
        let g:syntastic_ruby_rubocop_exec='~/.rubocop.sh'
        let g:syntastic_haml_checkers = ['haml_lint']
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
        let g:pymode_lint_checkers = ['pylint']
        let g:pymode_lint_config = '$HOME/.pylintrc'
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
        map <Leader>e :NERDTreeToggle<CR>
        let NERDTreeShowBookmarks=1
        let NERDTreeQuitOnOpen=1
        let NERDTreeMinimalUI=1
        let NERDTreeShowHidden=1
        let NERDTreeDirArrows=1
        let NERDTreeAutoDeleteBuffer=1
        autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
    " }

    " easy-align {
        " Start interactive EasyAlign in visual mode (e.g. vipga)
        xmap ga <Plug>(EasyAlign)

        " Start interactive EasyAlign for a motion/text object (e.g. gaip)
        nmap ga <Plug>(EasyAlign)
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
        let g:airline_theme = "molokai"
        let g:airline_powerline_fonts = 1
        let g:airline#extensions#syntastic#enabled = 0
        let g:airline#extensions#tabline#enabled = 1
        let g:airline#extensions#tabline#show_buffers = 0
        let g:airline#extensions#tabline#show_tabs = 1
        let g:airline#extensions#tabline#formatter = "default"
    " }

    " tmuxline {
        let g:tmuxline_theme = "molokai"
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
    set background=dark
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
    silent! colorscheme vividchalk

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
    set foldmethod=indent

    " Disable the annoying bells
    set noerrorbells visualbell t_vb=
    if has('autocmd')
        autocmd vimrc GUIEnter * set visualbell t_vb=
    endif
" }

" Formatting {
    " set nowrap
    set wrap
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
    autocmd FileType c,cpp,java,php,javascript,puppet,python,rust,twig,xml,yml,perl,sql autocmd BufWritePre <buffer> :call StripTrailingWhitespace()
    autocmd Filetype haskell,puppet,ruby,yml,eruby,coffee,html setlocal ts=2 sts=2 sw=2
    autocmd Filetype javascript,js,jsx,coffee,vimrc setlocal ts=4 sts=4 sw=4
    autocmd Filetype python setlocal ts=4 sts=4 sw=4 colorcolumn=120
    autocmd FileType make setlocal noexpandtab
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

    ""tabs
    :noremap <Leader>te :tabe<cr>v
    :noremap <Leader>tn gt
    :noremap <Leader>tp gT

    ""reset split
    :noremap <Leader>= <c-w>=<cr>
" }
