" Online I/O functions


if (exists ('g:dnnet'))
	finish
endif

let g:dnnet={'include': 1, 'path': $HOME.'./av.so'}

function! g:dnnet.url_get(url)
 return libcall(g:dnnet['path'], 'avio_url_write', json_encode (a:url))
endfun

function! g:dnnet.url_read(url)
 let d=g:dnnet.url_get(a:url)
 let m = json_decode(d)

 if (m['valid']==v:true)
  if len(m['contents'])>0
   :call setline(1, m['contents'])
  endif
 endif
endfun

function! g:dnnet.prepareWR(url, opts)
 :return {"url": a:url, "options": a:opts, "contents": getline (1, '$')}
endfun

function! g:dnnet.prepareRW(url, opts)
 :return {"url": a:url, "options": a:opts}
endfun

function! g:dnnet.url_write(url)
 return json_decode(g:dnnet.url_get(a:url))
endfun

function! g:dnnet.read(url, opts)
 :echo g:dnnet.url_read(g:dnnet.prepareRW(a:url, a:opts))
endfun
function! g:dnnet.write(url, opts)
 :echo g:dnnet.url_write(g:dnnet.prepareWR(a:url, a:opts))
endfun
