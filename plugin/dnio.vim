" Online I/O functions (Function For opening Read and Writing to Remote Files)
" Maintainer: Eddington Chamunorwa	 <dittonedo45@gmail.com>
" Last change:	2021 Dec 2


if (exists ('g:dnnet'))
" Check if DittoNedoNet class has been already called.
" if True the we are finshed.
	finish
endif

" Global look up Object For Object file.
let g:dnnet={'include': 1, 'path': $HOME.'./av.so'}

" Online Read function routine, to json string -> json_encode -> object.
function! g:dnnet.url_get(url)
" * Libcall of avio_url_write, a method that calls C library symbol.
" * json_encode (url) is for translating object -> string, which is required by
" libcall..
 return libcall(g:dnnet['path'], 'avio_url_write', json_encode (a:url))
endfun

function! g:dnnet.url_read(url)
 let d=g:dnnet.url_get(a:url)
 " Decode string to object{json}
 let m = json_decode(d)

 " Validity of the object is check, see vavio.c
 if (m['valid']==v:true)
  if len(m['contents'])>0
   " Insert lines from the withdraw contents to buffer.
   :call setline(1, m['contents'])
  endif
 endif
endfun

function! g:dnnet.prepareWR(url, opts)
" Preparation of Transmitting current Buffer Contents.
" And url, options in case of ftp options had to be 
" Something like {"user_name": "user", "user_password": "password" }
" getline (1, '$') Clones the whole buffer to and Array.

 :return {"url": a:url, "options": a:opts, "contents": getline (1, '$')}
endfun

function! g:dnnet.prepareRW(url, opts)
" Preparation of Receiving current Buffer Contents.
" And url, options in case of ftp options had to be 
" Something like {"user_name": "user", "user_password": "password" }
"
 :return {"url": a:url, "options": a:opts}
endfun

function! g:dnnet.url_write(url)
 return json_decode(g:dnnet.url_get(a:url))
endfun

function! g:dnnet.read(url, opts)
" The User Functions To use This one for reading.
 :echo g:dnnet.url_read(g:dnnet.prepareRW(a:url, a:opts))
endfun
function! g:dnnet.write(url, opts)
" The User Functions To use This one for writing.
 :echo g:dnnet.url_write(g:dnnet.prepareWR(a:url, a:opts))
endfun
