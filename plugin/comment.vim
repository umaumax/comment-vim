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

augroup filetypedetect
	" default comment
	au BufNewFile,BufRead * :call HeadComSet('#')

	au BufNewFile,BufRead .*profile  :call HeadComSet('#')
	au BufNewFile,BufRead .*rc       :call HeadComSet('#')
	au BufNewFile,BufRead .*env      :call HeadComSet('#')
	au BufNewFile,BufRead .*vimrc    :call HeadComSet('"')
	au BufNewFile,BufRead *config     :call HeadComSet('#') " for ~/.ssh/config
	" 	au BufNewFile,BufRead .tmux.conf :call HeadComSet('#')
	au BufNewFile,BufRead *.conf     :call HeadComSet('#')
	au BufNewFile,BufRead Dockerfile :call HeadComSet('#')
	au BufNewFile,BufRead .gitignore :call HeadComSet('#')
	au BufNewFile,BufRead .gitconfig :call HeadComSet('#')
	au BufNewFile,BufRead .Xmodmap   :call HeadComSet('!')

	au BufNewFile,BufRead Makefile :call HeadComSet('#')
	au BufNewFile,BufRead CMakeLists.txt :call HeadComSet('#')

	au BufNewFile,BufRead *.vim   :call HeadComSet('"')
	au BufNewFile,BufRead *.{sh,zsh} :call HeadComSet('#')
	au BufNewFile,BufRead *.cmake :call HeadComSet('#')
	au BufNewFile,BufRead *.awk   :call HeadComSet('#')
	au BufNewFile,BufRead *.py    :call HeadComSet('#')
	au BufNewFile,BufRead *.tml   :call HeadComSet('#')
	au BufNewFile,BufRead *.ninja :call HeadComSet('#')
	au BufNewFile,BufRead *.asm   :call HeadComSet(';') " for nasm
	au BufNewFile,BufRead *.s     :call HeadComSet('#')
	"	au BufNewFile,BufRead *.s     :call HeadComSet(';') " for plan9 asm
	au BufNewFile,BufRead *.{gnuplot,gnu,gp}    :call HeadComSet('#')

	au BufNewFile,BufRead * if @% !~ '\.' && getline(1) !~ '^#!.*' | call HeadComSet('#') | endif

	au BufNewFile,BufRead *.m          :call HeadComSet('\/\/')
	au BufNewFile,BufRead *.go         :call HeadComSet('\/\/')
	au BufNewFile,BufRead *.js         :call HeadComSet('\/\/')
	au BufNewFile,BufRead *.{h,hpp}    :call HeadComSet('\/\/')
	au BufNewFile,BufRead *.{c,cc,cpp} :call HeadComSet('\/\/')

	au BufNewFile,BufRead *.{html,md} :call SandComSet('<!--', '-->')
	au BufNewFile,BufRead *.css  :call SandComSet('\/\*', '\*\/')
augroup END

" pop user setting
let &cpo = s:save_cpo
unlet s:save_cpo
