scriptencoding utf-8

if exists('g:loaded_comment')
	finish
endif
let g:loaded_comment = 1

"let s:file_size = getfsize(expand(@%))
"if s:file_size > 0
"	finish
"endif

" push user setting
let s:save_cpo = &cpo
set cpo&vim

function! HeadComSet(char)
	" comment
	" <C-_> = <C-/>
	execute 'nnoremap \\          :s/^\(.*\)$/' . a:char . ' \1<CR>:noh<CR>'
	execute 'vnoremap \\          :s/^\(.*\)$/' . a:char . ' \1<CR>:noh<CR>'
	execute 'inoremap <C-_>  <ESC>:s/^\(.*\)$/' . a:char . ' \1<CR>:noh<CR>i'
	" uncomment
	execute 'nnoremap \|\|        :s/^\s*' . a:char . '\s*\(.*\)$/\1/<CR>:noh<CR>'
	execute 'vnoremap \|\|        :s/^\s*' . a:char . '\s*\(.*\)$/\1/<CR>:noh<CR>'
	execute 'inoremap <C-\|> <ESC>:s/^\s*' . a:char . '\s*\(.*\)$/\1/<CR>:noh<CR>i'
endfunction

function! SandComSet(char1, char2)
	" comment
	execute 'nnoremap \\          :s/^\s*\(.*\)$/' . a:char1 . ' \1 ' . a:char2 . '<CR>:noh<CR>'
	execute 'vnoremap \\          :s/^\s*\(.*\)$/' . a:char1 . ' \1 ' . a:char2 . '<CR>:noh<CR>'
	execute 'inoremap <C-_>  <ESC>:s/^\s*\(.*\)$/' . a:char1 . ' \1 ' . a:char2 . '<CR>:noh<CR>i'
	" uncomment
	execute 'nnoremap \|\|        :s/^\s*' . a:char1 . '\s*\(.\{-}\)\s*'. a:char2 . '\s*$/\1/<CR>:noh<CR>'
	execute 'vnoremap \|\|        :s/^\s*' . a:char1 . '\s*\(.\{-}\)\s*'. a:char2 . '\s*$/\1/<CR>:noh<CR>'
	execute 'inoremap <C-\|> <ESC>:s/^\s*' . a:char1 . '\s*\(.\{-}\)\s*'. a:char2 . '\s*$/\1/<CR>:noh<CR>i'
endfunction

augroup filetypedetect
	au BufNewFile,BufRead .*profile  :call HeadComSet('#')
	au BufNewFile,BufRead .*rc       :call HeadComSet('#')
	au BufNewFile,BufRead .vimrc     :call HeadComSet('"')
	au BufNewFile,BufRead config     :call HeadComSet('#') " for ~/.ssh/config
	au BufNewFile,BufRead .tmux.conf :call HeadComSet('#')
	au BufNewFile,BufRead Dockerfile :call HeadComSet('#')
	au BufNewFile,BufRead .gitignore :call HeadComSet('#')
	au BufNewFile,BufRead .gitconfig :call HeadComSet('#')

	au BufNewFile,BufRead Makefile :call HeadComSet('#')
	au BufNewFile,BufRead CMakeLists.txt :call HeadComSet('#')

	au BufNewFile,BufRead *.vim   :call HeadComSet('"')
	au BufNewFile,BufRead *.sh    :call HeadComSet('#')
	au BufNewFile,BufRead *.cmake :call HeadComSet('#')
	au BufNewFile,BufRead *.awk   :call HeadComSet('#')
	au BufNewFile,BufRead *.py    :call HeadComSet('#')
	au BufNewFile,BufRead *.md    :call HeadComSet('#')
	au BufNewFile,BufRead *.tml   :call HeadComSet('#')
	au BufNewFile,BufRead *.ninja :call HeadComSet('#')
	au BufNewFile,BufRead *.asm   :call HeadComSet(';') " for nasm
	au BufNewFile,BufRead *.s     :call HeadComSet('#')
"	au BufNewFile,BufRead *.s     :call HeadComSet(';') " for plan9 asm
	au BufNewFile,BufRead *.{gnuplot,gnu,gp}    :call HeadComSet('#')

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
