" Bare vim for exam-style coding practice: plain syntax colours like Inspera, no completion, no plugins.
" Loaded by `studie kode` with -u, so the normal vim setup is never read.
set nocompatible
filetype plugin indent off
syntax on

set number
set autoindent
set backspace=indent,eol,start
set ruler
set laststatus=2
set expandtab tabstop=2 shiftwidth=2 softtabstop=2

" The files live in Nextcloud, which would sync swap and undo files to every machine
set noswapfile nobackup nowritebackup noundofile

" Vim completes words even without plugins
set complete= completeopt= omnifunc= completefunc=
inoremap <C-n> <Nop>
inoremap <C-p> <Nop>
inoremap <C-x> <Nop>
