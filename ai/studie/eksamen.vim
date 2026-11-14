" Bare vim for exam-style coding practice: plain syntax colours like Inspera, no completion, no plugins.
" Loaded by `studie kode` and `studie nå` with -u, so the normal vim setup is never read.
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

" The session pane rewrites the task file between answers, so reload without asking.
" Polling, because vim keeps focus while the file changes in another pane.
set autoread
call timer_start(500, {-> execute('silent! checktime')}, {'repeat': -1})
autocmd FileChangedShellPost * call s:GoToAnswer()

function! s:GoToAnswer() abort
  if search('^## Svar', 'w')
    normal! j
  endif
endfunction

" A coding task names its code file on a line of its own. `studie nå` then shows that file instead
" of the task file, and goes back to the task file when the next item is not code.
let s:task = empty($STUDIE_TASK) ? '' : fnamemodify($STUDIE_TASK, ':p')
let s:task_time = -1

function! s:CodeFile() abort
  for line in readfile(s:task)
    let path = trim(line)
    if path =~# '^/' && path !=# s:task && filereadable(path)
      return path
    endif
  endfor
  return ''
endfunction

function! s:Follow() abort
  if empty(s:task) || getftime(s:task) == s:task_time
    return
  endif
  let s:task_time = getftime(s:task)
  let target = s:CodeFile()
  let target = empty(target) ? s:task : target
  if expand('%:p') ==# target
    return
  endif
  " An unsent answer must not overwrite the new item: wait, and let checktime ask as before
  if &modified && expand('%:p') ==# s:task
    let s:task_time = -1
    return
  endif
  " Unsaved code would block the switch, and the file is handed in anyway
  silent! update
  execute 'edit' fnameescape(target)
  if target ==# s:task
    call s:GoToAnswer()
  endif
endfunction

if !empty(s:task)
  autocmd VimEnter * ++nested call s:Follow()
  call timer_start(500, {-> s:Follow()}, {'repeat': -1})
endif

" :make compiles and runs the open code file with `studie kjør`, so the first run is still saved as the attempt.
" Only compiler messages go to the quickfix list, so program output never looks like an error location.
function! s:SetMake() abort
  if expand('%:e') !~# '^\(c\|cu\|s\|S\|py\)$' || empty($STUDIE_BIN)
    return
  endif
  " studie kjør builds a copy in a cache folder, so relative names in its messages refer to this folder
  lcd %:p:h
  let &l:makeprg = shellescape($STUDIE_BIN) . ' kjør ' . shellescape(expand('%:p'))
  setlocal errorformat=%f:%l:%c:\ %trror:\ %m,%f:%l:%c:\ %tarning:\ %m,%f:%l:\ %trror:\ %m,%f:%l:\ Error:\ %m,%-G%.%#
endfunction
autocmd BufEnter * call s:SetMake()

" <Space>s saves and hands the file to the Claude session that `studie` started in tmux
let mapleader = " "
nnoremap <silent> <Leader>s :call <SID>Submit()<CR>
command! Svar call s:Submit()

function! s:Submit() abort
  silent write
  let pane = trim(system('tmux show-options -gqv @studie_claude'))
  if empty(pane) || trim(system('tmux display-message -p -t ' . shellescape(pane) . ' "#{pane_current_command}" 2>/dev/null')) !=# 'claude'
    echohl ErrorMsg | echo 'Fant ingen Claude-økt i tmux. Start den med studie okt.' | echohl None
    return
  endif
  call system('tmux send-keys -t ' . shellescape(pane) . ' -l ' . shellescape('svar ' . expand('%:p')))
  " Claude Code reads a fast burst of keys as a paste, so Enter must arrive after it
  call system('sleep 0.3; tmux send-keys -t ' . shellescape(pane) . ' Enter')
  redraw | echo 'Sendt til Claude.'
endfunction
