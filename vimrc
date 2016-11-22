call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'ctrlpvim/ctrlp.vim'
Plug 'rking/ag.vim'
Plug 'scrooloose/syntastic'
Plug 'scrooloose/nerdcommenter'
Plug 'luochen1990/rainbow'
Plug 'ervandew/supertab'
Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-fugitive'
Plug 'klen/python-mode'
Plug 'davidhalter/jedi-vim'
Plug 'vim-ruby/vim-ruby'
Plug 'mitsuhiko/vim-jinja'
Plug 'pangloss/vim-javascript'
Plug 'walm/jshint.vim'
Plug 'plasticboy/vim-markdown'
Plug 'kchmck/vim-coffee-script'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'flazz/vim-colorschemes'
Plug 'altercation/vim-colors-solarized'
Plug 'edkolev/tmuxline.vim'
Plug 'godlygeek/tabular'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'majutsushi/tagbar'
Plug 'Valloric/YouCompleteMe', { 'for': 'cpp', 'do': './install.py --clang-completer' }
autocmd! User YouCompleteMe if !has('vim_starting') | call youcompleteme#Enable() | endif
call plug#end()
let mapleader=","
au FocusLost,TabLeave * call feedkeys("\<C-\>\<C-n>")
"" Some new configurations
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h
"" Tagbar
map <Leader>tb :TagbarToggle<CR>
"" NERDTree
let NERDTreeMinimalUI=1
let NERDTreeDirArrows=1
let NERDTreeQuitOnOpen=1
let NERDTreeAutoDeleteBuffer=1
let NERDTreeShowBookmarks=1
map <Leader>n :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
"" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l
""Vertical split then hop to new buffer
:noremap <Leader>v <c-w>v<cr>
:noremap <Leader>h <c-w>s<cr>
:noremap <Leader>V <c-w>t<c-w>H<cr>
:noremap <Leader>H <c-w>t<c-w>K<cr>
"" Tabular
nmap <Leader>t= :Tabularize /=<CR>
vmap <Leader>t= :Tabularize /=<CR>
nmap <Leader>t{ :Tabularize /{<CR>
vmap <Leader>t{ :Tabularize /{<CR>
nmap <Leader>t=> :Tabularize /=><CR>
vmap <Leader>t=> :Tabularize /=><CR>
nmap <Leader>t: :Tabularize /:\zs<CR>
vmap <Leader>t: :Tabularize /:\zs<CR>
nmap <Leader>t, :Tabularize /,\zs<CR>
vmap <Leader>t, :Tabularize /,\zs<CR>
""reset split
:noremap <Leader>= <c-w>=<cr>
"" set color depth
set term=xterm-256color
"" space not tab
set expandtab
set smarttab
autocmd Filetype html setlocal ts=2 sts=2 sw=2
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
autocmd Filetype eruby setlocal ts=2 sts=2 sw=2
autocmd Filetype javascript setlocal ts=4 sts=4 sw=4
autocmd Filetype coffee setlocal ts=2 sts=2 sw=2
autocmd Filetype python setlocal ts=4 sts=4 sw=4 colorcolumn=80
set laststatus=2                  " always show status line
" NERDCommenter
let NERDDefaultAlign = 'left'
" YCM
let g:ycm_path_to_python_interpreter = '$HOME/.pyenv/shims/python'
"" ctrlp
let g:ctrlp_custom_ignore = 'vendor/ruby/\|node_modules/\|tmp/|coverage/'
map <Leader>b :CtrlPBuffer<CR>
map <Leader>m :CtrlPMRU<CR>
"" vim-indent-guides
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
let g:indent_guides_enable_on_vim_startup = 1
"" Syntastic
"" from https://github.com/scrooloose/syntastic#3-recommended-settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
"" Syntastic python
autocmd FileType python let g:syntastic_check_on_wq = 0
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
"" airline
let g:airline_theme = "wombat"
let g:airline_powerline_fonts = 1
"" tmuxline
let g:tmuxline_theme = "wombat"
"" Python mode
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
"" Rainbow parens
let g:rainbow_active = 1
"" Jedi Vim
let g:jedi#use_splits_not_buffers = "right"
let g:jedi#completions_enabled = 0
filetype indent plugin on
syntax on
set cursorline
"" autoindent
set ai
"" smartindent
set si
"" ignore case on search
set ignorecase
"" set incsearch
"" highlight search results
set hlsearch
"" show matching brackets
set showmatch
"" and blink for 2 seconds
set mat=2
"" disable error bells
set noerrorbells
set novisualbell
"" disable code folding
set nofoldenable
"" enable code folding
"" set foldmethod=indent
"" nnoremap <space> za
"" vnoremap <space> zf
"" show line numbers
set number
"" No backups
set nobackup
set nowritebackup
"" No swap files; more hassle then they're worth
set noswapfile
"" colors
"" Softer diff colors
set background=dark
silent! colorscheme vividchalk
call togglebg#map("<F5>")
highlight ColorColumn ctermbg=234 guibg=#2c2d27

if $TMUX == ''
  set clipboard+=unnamed
endif
