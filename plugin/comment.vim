scriptencoding utf-8

if exists('g:loaded_comment')
	finish
endif
let g:loaded_comment = 1

" push user setting
let s:save_cpo = &cpo
set cpo&vim

function! Substitute(pat, sub, flags) range
	for l:n in range(a:firstline, a:lastline)
		let l:line=getline(l:n)
		let l:ret=substitute(l:line, a:pat, a:sub, a:flags)
		call setline(l:n, l:ret)
	endfor
	call cursor(a:lastline+1, 1)
endfunction

" pick up arg
function! Args(index, ...)
	let l:arg = get(a:, a:index, '')
	return l:arg
endfunction

command! -nargs=1 -range   HeadComSub <line1>,<line2>call Substitute('^\(.*\)$', <args> . ' \1', '')
command! -nargs=1 -range UnHeadComSub <line1>,<line2>call Substitute('^\s*' . <args> . '[ ]\?\(\s*.*\)$', '\1', '')
command! -nargs=+ -range   SandComSub <line1>,<line2>call Substitute('^\s*\(.*\)$', Args(1, <f-args>) . ' \1 ' . Args(2, <f-args>), '')
command! -nargs=+ -range UnSandComSub <line1>,<line2>call Substitute('^\s*' . Args(1, <f-args>) . '\s*\(.\{-}\)\s*'. Args(2, <f-args>) . '\s*$', '\1', '')

function! HeadComSet(char)
	" comment
	" <C-_> = <C-/>
	let l:cmd=':HeadComSub(' ."'". a:char ."'" . ')<CR>'
	execute 'nnoremap <silent> \  ' . l:cmd
	execute 'vnoremap <silent> \  ' . l:cmd
	execute 'nnoremap <silent> \\ ' . l:cmd
	execute 'vnoremap <silent> \\ ' . l:cmd
	execute 'inoremap <silent> <C-_> <ESC>' . l:cmd . 'i'
	" uncomment
	let l:cmd=':UnHeadComSub(' ."'". a:char ."'". ')<CR>'
	execute 'nnoremap \|   ' . l:cmd
	execute 'vnoremap \|   ' . l:cmd
	execute 'nnoremap \|\| ' . l:cmd
	execute 'vnoremap \|\| ' . l:cmd
	execute 'inoremap <C-\|> <ESC>' . l:cmd . 'i'
endfunction

function! SandComSet(char1, char2)
	" comment
	let l:cmd=':SandComSub ' . a:char1 .' '. a:char2 . '<CR>'
	execute 'nnoremap <silent> \  ' . l:cmd
	execute 'nnoremap \  ' . l:cmd
	execute 'vnoremap \  ' . l:cmd
	execute 'nnoremap \\ ' . l:cmd
	execute 'vnoremap \\ ' . l:cmd
	execute 'inoremap <C-_> <ESC>' . l:cmd . 'i'
	" uncomment
	let l:cmd=':UnSandComSub ' . a:char1 .' '. a:char2 . '<CR>'
	execute 'nnoremap \|   ' . l:cmd
	execute 'vnoremap \|   ' . l:cmd
	execute 'nnoremap \|\| ' . l:cmd
	execute 'vnoremap \|\| ' . l:cmd
	execute 'inoremap <C-\|> <ESC>' . l:cmd . 'i'
endfunction

augroup commenti-vim_filetype_detect
	" default comment
	au BufEnter * :call HeadComSet('#')
	au BufEnter * if @% !~ '\.' && getline(1) !~ '^#!.*' | call HeadComSet('#') | endif

	au BufEnter .*profile  :call HeadComSet('#')
	au BufEnter .*rc       :call HeadComSet('#')
	au BufEnter .*env      :call HeadComSet('#')
	au BufEnter .*vimrc    :call HeadComSet('"')
	au BufEnter *config     :call HeadComSet('#') " for ~/.ssh/config
	" 	au BufEnter .tmux.conf :call HeadComSet('#')
	au BufEnter *.conf     :call HeadComSet('#')
	au BufEnter Dockerfile :call HeadComSet('#')
	au BufEnter .gitignore :call HeadComSet('#')
	au BufEnter .gitconfig :call HeadComSet('#')
	au BufEnter .Xmodmap   :call HeadComSet('!')

	au BufEnter Makefile :call HeadComSet('#')
	au BufEnter CMakeLists.txt :call HeadComSet('#')

	au BufEnter *.vim   :call HeadComSet('"')
	au BufEnter *.{sh,zsh} :call HeadComSet('#')
	au BufEnter *.cmake :call HeadComSet('#')
	au BufEnter *.awk   :call HeadComSet('#')
	au BufEnter *.py    :call HeadComSet('#')
	au BufEnter *.tml   :call HeadComSet('#')
	au BufEnter *.ninja :call HeadComSet('#')
	au BufEnter *.asm   :call HeadComSet(';') " for nasm
	au BufEnter *.s     :call HeadComSet('#')
	"	au BufEnter *.s     :call HeadComSet(';') " for plan9 asm
	au BufEnter *.{gnuplot,gnu,gp}    :call HeadComSet('#')

	au BufEnter *.m          :call HeadComSet('\/\/')
	au BufEnter *.go         :call HeadComSet('\/\/')
	au BufEnter *.js         :call HeadComSet('\/\/')
	au BufEnter *.{h,hpp}    :call HeadComSet('\/\/')
	au BufEnter *.{c,cc,cpp} :call HeadComSet('\/\/')

	au BufEnter *.{html,md} :call SandComSet('<!--', '-->')
	au BufEnter *.css  :call SandComSet('\/\*', '\*\/')
augroup END

" pop user setting
let &cpo = s:save_cpo
unlet s:save_cpo
