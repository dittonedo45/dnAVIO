synt on
set showcmd
set showmatch
set ignorecase
set smartcase
set incsearch
set autowrite
set ai
set hidden
set mouse=a
set updatetime=1

if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif
func! FixC()
if &ft=='c'
	call append (line ('$')-1, '#include <stdio.h>')
	call append (line ('$')-1, '#include <stdlib.h>')
	call append (line ('$')-1, '#include <unistd.h>')
	call append (line ('$')-1, '')
	call append (line ('$')-1, 'int main ( signed Argsc, char *(Args[]) ) {')
	call append (line ('$')-1, '')
	call append (line ('$')-1, "\t".'return 0;')
	call append (line ('$')-1, '}')
elseif &ft=='cpp' || &ft=='cxx'
	call append (line ('$')-1, '#include <iostream>')
	call append (line ('$')-1, '#include <cstdio>')
	call append (line ('$')-1, '#include <cstdlib>')
	call append (line ('$')-1,  '')
	call append (line ('$')-1, 'using namespace std;')
	call append (line ('$')-1,  '')
	call append (line ('$')-1, 'int main ( int Argsc, char *(Args[]) ) {')
	call append (line ('$')-1, '')
	call append (line ('$')-1, "\t".'return 0;')
	call append (line ('$')-1, '}')
endif
endfunc
map hh <esc>:call FixC()<cr>
set path+=/usr/include,/usr/local/include,$HOME/usr/include
set nu
set nuw=1
hi LineNr ctermbg=white ctermfg=black cterm=bold
hi EndOfBuffer ctermbg=black ctermfg=black
function! Edd()
	if &ft=='c' || &ft=='cpp' || &ft=='cxx'
		%d
		call FixC()
	endif
endfunc
set cindent
function HeaderMagic()
	if  !&ro && ( &ft=='c' || &ft=='cpp' || &ft=='cxx' )
		let lin=line('.')
		if &ft=='c'
			call append (lin,'#include <.h>')
		else
			call append (lin,'#include <>')
		endif
		call cursor(lin+1,11)
	else 
		if match(getline(line('.')),'^#')
			call setline (line ('.'),'#'.getline(line('.')))
		else
			call setline (line ('.'),substitute(getline(line('.')),'^#','','g') )
		endif
	endif
endfunc
map ff <esc>:call HeaderMagic()<cr>
function HateMercy ()
if line ('$')-1==0
	:call FixC ()
endif
endfunc

autocmd BufNewFile *.c,*.cpp,*.cxx call HateMercy ()

function Anony ()
	let Lsl=line ('.')
	%!indent  -i 1 -linux -nbfda -nsaw -nsaf -pcs -prs -nsai -ts4 -as 2> /dev/null
	"%!indent  -i 4 -linux 2> /dev/null
	call execute (':'+string (Lsl))
endfunc
autocmd BufWrite *.c,*.cpp call Anony ()
let g:LastMinute=0
func EddColorSchemeChange ()
return
	let DesCide=strftime ('%M')%7
	if (g:LastMinute==DesCide)
		if (DesCide==0)
			colors koehler
		elseif (DesCide==1)
			colors murphy
		elseif (DesCide==2)
			colors default
		elseif (DesCide==3)
			colors delek
		elseif (DesCide==4)
			colors desert
		elseif (DesCide==5)
			colors eddy
		elseif (DesCide==6)
			colors elflord
		endif
	else
		let g:LastMinute=DesCide
	endif
endfun
func MyWrite ()
	if &modifiable && !&readonly && !&modified
		:w
	endif
endfunc

set backup
set backupdir=~/VimBU
set backupskip='\.[^c]$'
set updatetime=1


source ~/oky.vim
map ; :w!<cr>
map , :qall!<cr>
set cursorline
hi CursorLine cterm=italic ctermfg=black ctermbg=white

"GitHub Auto Adding
fun MyGitWrite ()
try
call system ('git add "'.substitute (execute ('pwd').bufname('%'), '^\v[^/]', '', 'g').'"')
catch
endtry
endfun
fun MyGitCommiter ()
	let l:mypath=''
	if (match(bufname('%'), '/[^/]\+$'))
		let l:mypath=substitute(bufname('%'), '/[^/]\+$', '', 'g')
	else
		let l:mypath=substitute (execute ('pwd').bufname('%'), '^\v[^/]', '', 'g')
	endif
	echo 
	try
	if (execute('pwd')==l:mypath)
		call system ('git init ')
		call system ('git commit -m "'.strftime('%A %d %B %Y %H:%M:%S').'" ')
		endif
	catch
	echoerr glob(l:mypath)
	endtry

endfun

map cc :call MyGitCommiter ()<cr>
autocmd BufWrite *.*,*vimrc :call MyGitWrite()
color desert
