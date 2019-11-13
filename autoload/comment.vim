scriptencoding utf-8

if !exists('g:loaded_comment')
  finish
endif
let g:loaded_comment = 1

let s:save_cpo = &cpo
set cpo&vim

function! comment#ls(path)
  let l:ret = system('ls ' . a:path)
  return split(l:ret, "\n")
endfunction

function! comment#dialog(message, list)
  let l:choices = ''
  let l:i = 0
  for l:val in a:list
    let l:choices .= nr2char(char2nr('A') + l:i) . ' ' . l:val . "\n"
    let l:i += 1
  endfor
  return confirm(a:message, l:choices) - 1
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
