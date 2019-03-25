scriptencoding utf-8

if exists('g:loaded_comment')
	finish
endif
let g:loaded_comment = 1

" push user setting
let s:save_cpo = &cpo
set cpo&vim

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

function! HeadComSet(char)
	" comment
	" <C-_> = <C-/>
	let l:cmd=':HeadComSub(' ."'". a:char ."'" . ')<CR>'
	execute 'nnoremap <silent> \  ' . l:cmd
	execute 'vnoremap <silent> \  ' . l:cmd
	execute 'inoremap <silent> <C-_> <ESC>' . l:cmd . 'i'
	" uncomment
	let l:cmd=':UnHeadComSub(' ."'". a:char ."'". ')<CR>'
	execute 'nnoremap \|   ' . l:cmd
	execute 'vnoremap \|   ' . l:cmd
	execute 'inoremap <C-\|> <ESC>' . l:cmd . 'i'
endfunction

function! SandComSet(char1, char2)
	" comment
	let l:cmd=':SandComSub ' . a:char1 .' '. a:char2 . '<CR>'
	execute 'nnoremap <silent> \  ' . l:cmd
	execute 'nnoremap \  ' . l:cmd
	execute 'vnoremap \  ' . l:cmd
	execute 'inoremap <C-_> <ESC>' . l:cmd . 'i'
	" uncomment
	let l:cmd=':UnSandComSub ' . a:char1 .' '. a:char2 . '<CR>'
	execute 'nnoremap \|   ' . l:cmd
	execute 'vnoremap \|   ' . l:cmd
	execute 'inoremap <C-\|> <ESC>' . l:cmd . 'i'
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

	autocmd BufEnter Makefile       :call HeadComSet('#')
	autocmd BufEnter CMakeLists.txt :call HeadComSet('#')

	autocmd BufEnter .*vimrc            :call HeadComSet('"')
	autocmd BufEnter *.vim              :call HeadComSet('"')
	autocmd BufEnter *.{sh,zsh}         :call HeadComSet('#')
	autocmd BufEnter *.cmake            :call HeadComSet('#')
	autocmd BufEnter *.awk              :call HeadComSet('#')
	autocmd BufEnter *.py               :call HeadComSet('#')
	autocmd BufEnter *.tml              :call HeadComSet('#')
	autocmd BufEnter *.ninja            :call HeadComSet('#')
	autocmd BufEnter *.{gnuplot,gnu,gp} :call HeadComSet('#')
	" NOTE: for nasm or plan9 asm
	autocmd BufEnter *.asm :call HeadComSet(';')
	autocmd BufEnter *.s   :call HeadComSet('#')

	autocmd BufEnter *.m              :call HeadComSet('\/\/')
	autocmd BufEnter *.go             :call HeadComSet('\/\/')
	autocmd BufEnter *.js             :call HeadComSet('\/\/')
	autocmd BufEnter *.jenkins{,file} :call HeadComSet('\/\/')
	autocmd BufEnter *.{h,hh,hpp}     :call HeadComSet('\/\/')
	autocmd BufEnter *.{c,cc,cpp,cxx} :call HeadComSet('\/\/')

	autocmd BufEnter *.css                  :call SandComSet('\/\*', '\*\/')
	autocmd BufEnter *.{html,xml,md,launch} :call SandComSet('<!--', '-->')
augroup END

" pop user setting
let &cpo = s:save_cpo
unlet s:save_cpo
