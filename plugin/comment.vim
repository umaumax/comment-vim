scriptencoding utf-8

if exists('g:loaded_comment')
  finish
endif
let g:loaded_comment = 1

" push user setting
let s:save_cpo = &cpo
set cpo&vim

function! GetIndentStr(line_no)
  let indent_str=0
  if &expandtab == 1
    let indent_str = repeat(' ', indent(a:line_no))
  else
    let indent_str = repeat("\t", indent(a:line_no) / &tabstop)
  endif
  return indent_str
endfunction

function! InsertRangeComment(start_str, end_str) range
  call append(a:lastline, GetIndentStr(a:lastline).a:end_str)
  call append(a:firstline-1, GetIndentStr(a:firstline).a:start_str)
endfunction

function! PythonComment() range
  if a:firstline == a:lastline
    " single line comment
    execute a:firstline.','.a:lastline."HeadComSub '#'"
  else
    " multi lines comment
    execute a:firstline.','.a:lastline."call InsertRangeComment('\"\"\"', '\"\"\"')"
  endif
endfunction

function! PythonUnComment() range
  let tmp_search_word = @/
  " single and multi line comment
  execute a:firstline.','.a:lastline."UnHeadComSub '#'"
  " multi lines comment
  execute (a:lastline).','.(a:lastline+1).'g/"""/d'
  execute (a:firstline-1).','.(a:firstline).'g/"""/d'
  let @/ = tmp_search_word
endfunction

command! -nargs=0 -range PythonComment <line1>,<line2>call PythonComment()
command! -nargs=0 -range PythonUnComment <line1>,<line2>call PythonUnComment()

function! Substitute(pat, sub, flags) range
  for n in range(a:firstline, a:lastline)
    let line=getline(n)
    let line=substitute(line, a:pat, a:sub, a:flags)
    let line=substitute(line, '\s*$', '','')
    call setline(n, line)
  endfor
  call cursor(a:lastline+1, 1)
endfunction

" pick up arg
function! Args(index, ...)
  let l:arg = get(a:, a:index, '')
  return l:arg
endfunction

command! -nargs=1 -range   HeadComSub <line1>,<line2>call Substitute('^\(\s*\)\(.*\)$', '\1'. <args> . ' \2', '')
command! -nargs=1 -range UnHeadComSub <line1>,<line2>call Substitute('^\(\s*\)' . <args> . '[ ]\?\(\s*.*\)$', '\1\2', '')
command! -nargs=+ -range   SandComSub <line1>,<line2>call Substitute('^\s*\(.*\)$', Args(1, <f-args>) . ' \1 ' . Args(2, <f-args>), '')
command! -nargs=+ -range UnSandComSub <line1>,<line2>call Substitute('^\s*' . Args(1, <f-args>) . '\s*\(.\{-}\)\s*'. Args(2, <f-args>) . '\s*$', '\1', '')

function! SetCommentKeyMapping(comment_cmd, uncomment_cmd)
  " comment
  " <C-_> = <C-/>
  execute 'nnoremap <silent> \  ' . a:comment_cmd . '<CR>'
  execute 'vnoremap <silent> \  ' . a:comment_cmd . '<CR>'
  execute 'inoremap <silent> <C-_> <ESC>' . a:comment_cmd . '<CR>' . 'i'
  " uncomment
  execute 'nnoremap \|   ' . a:uncomment_cmd . '<CR>'
  execute 'vnoremap \|   ' . a:uncomment_cmd . '<CR>'
  execute 'inoremap <C-\|> <ESC>' . a:uncomment_cmd . '<CR>' . 'i'
endfunction

function! HeadComSet(char)
  let l:comment_cmd  =':HeadComSub(' ."'". a:char ."'" . ')'
  let l:uncomment_cmd=':UnHeadComSub(' ."'". a:char ."'". ')'
  call SetCommentKeyMapping(comment_cmd, uncomment_cmd)
endfunction

function! SandComSet(char1, char2)
  let l:comment_cmd  =':SandComSub '   . a:char1 .' '. a:char2
  let l:uncomment_cmd=':UnSandComSub ' . a:char1 .' '. a:char2
  call SetCommentKeyMapping(comment_cmd, uncomment_cmd)
endfunction

augroup commenti-vim_filetype_detect
  " default comment
  autocmd BufEnter * :call HeadComSet('#')

  autocmd BufEnter .*profile  :call HeadComSet('#')
  autocmd BufEnter .*rc       :call HeadComSet('#')
  autocmd BufEnter .*env      :call HeadComSet('#')
  " NOTE: for ~/.ssh/config
  autocmd BufEnter *config    :call HeadComSet('#')
  " NOTE: for .tmux.conf
  autocmd BufEnter *.conf     :call HeadComSet('#')
  autocmd BufEnter Dockerfile :call HeadComSet('#')
  autocmd BufEnter .gitignore :call HeadComSet('#')
  autocmd BufEnter .gitconfig :call HeadComSet('#')
  autocmd BufEnter .Xmodmap   :call HeadComSet('!')

  autocmd BufEnter Makefile         :call HeadComSet('#')
  autocmd BufEnter {Make,make}.conf :call HeadComSet('#')
  autocmd BufEnter CMakeLists.txt   :call HeadComSet('#')

  autocmd BufEnter .*vimrc            :call HeadComSet('"')
  autocmd BufEnter *.vim              :call HeadComSet('"')
  autocmd BufEnter *.{sh,zsh}         :call HeadComSet('#')
  autocmd BufEnter *.cmake            :call HeadComSet('#')
  autocmd BufEnter *.awk              :call HeadComSet('#')
  autocmd BufEnter *.{tml,toml}       :call HeadComSet('#')
  autocmd BufEnter *.ninja            :call HeadComSet('#')
  autocmd BufEnter *.{gnuplot,gnu,gp} :call HeadComSet('#')
  " NOTE: for nasm or plan9 asm
  autocmd BufEnter *.asm    :call HeadComSet(';')
  " NOTE: for llvm ir
  autocmd BufEnter *.ll     :call HeadComSet(';')
  " NOTE: for perl Reply setting file
  autocmd BufEnter .replyrc :call HeadComSet(';')

  autocmd BufEnter *.s :call HeadComSet('#')

  autocmd BufEnter *.m              :call HeadComSet('\/\/')
  autocmd BufEnter *.go             :call HeadComSet('\/\/')
  autocmd BufEnter *.js             :call HeadComSet('\/\/')
  autocmd BufEnter *.jenkins{,file} :call HeadComSet('\/\/')
  autocmd BufEnter *.groovy         :call HeadComSet('\/\/')
  autocmd BufEnter *.{h,hh,hpp}     :call HeadComSet('\/\/')
  autocmd BufEnter *.{c,cc,cpp,cxx} :call HeadComSet('\/\/')
  autocmd BufEnter *.rs             :call HeadComSet('\/\/')
  autocmd BufEnter *.dot            :call HeadComSet('\/\/')
  " NOTE: for yacc file
  autocmd BufEnter *.y              :call HeadComSet('\/\/')
  " NOTE: for nex [blynn/nex: Lexer for Go]( https://github.com/blynn/nex )
  autocmd BufEnter *.nex            :call HeadComSet('\/\/')

  " autocmd BufEnter *.py               :call HeadComSet('#')
  autocmd BufEnter *.py             :call SetCommentKeyMapping(':PythonComment', ':PythonUnComment')

  autocmd BufEnter *.css                  :call SandComSet('\/\*', '\*\/')
  autocmd BufEnter *.{html,xml,md,launch} :call SandComSet('<!--', '-->')
augroup END

" pop user setting
let &cpo = s:save_cpo
unlet s:save_cpo
