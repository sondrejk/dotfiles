" Bare vim for exam-style coding practice: no highlighting, no completion, no plugins.
" Loaded by `studie kode` with -u, so the normal vim setup is never read.
set nocompatible
syntax off
filetype off
filetype plugin indent off

set number
set autoindent
set backspace=indent,eol,start
set ruler
set laststatus=2
set tabstop=4 shiftwidth=4

" The files live in Nextcloud, which would sync swap and undo files to every machine
set noswapfile nobackup nowritebackup noundofile

" Vim completes words even without plugins
set complete= completeopt= omnifunc= completefunc=
inoremap <C-n> <Nop>
inoremap <C-p> <Nop>
inoremap <C-x> <Nop>
