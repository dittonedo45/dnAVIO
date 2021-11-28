function! DNurl_read(url)
 let l:dstr=libcall($HOME.'/av.so', 'avio_url', json_encode (a:url))
 let l:my_object = json_decode (l:dstr)

 if (l:my_object['valid']==v:true)
  let cnts = reverse (l:my_object['contents'])
  if len(cnts)>0
		  call setline (line('.')+1, cnts)
  endif
 endif
endfun

function! DNurl_get(url)
 return libcall($HOME.'/av.so', 'avio_url', json_encode (a:url))
endfun

function! DNprepareBuf()
		return getline (1,'$')
endfun

function! DNprepareUO (url, opts)
	return {"url": a:url, "options": a:opts}
endfun
function! DNurl_read(url)
 let l:dstr=libcall($HOME.'/av.so', 'avio_url', json_encode (a:url))
 let l:my_object = json_decode (l:dstr)

 if (l:my_object['valid']==v:true)
  let cnts =  (l:my_object['contents'])
  if len(cnts)
		  call setline (1,cnts)
  endif
 endif
endfun

function! DNprepareUO (url, opts)
	return {"url": a:url, "options": a:opts}
endfun

function! DNprepareWR (url, opts)
	return {"url": a:url, "options": a:opts, "contents": DNprepareBuf ()}
endfun

function! DNurl_write(url)
 let l:dstr=libcall($HOME.'/av.so', 'avio_url_write', json_encode (a:url))
 let l:my_object = json_decode (l:dstr)

 echo l:my_object
endfun

function! DNprepareWR (url, opts)
	return {"url": a:url, "options": a:opts, "contents": DNprepareBuf ()}
endfun

function! DNurl_write(url)
 let l:dstr=libcall($HOME.'/av.so', 'avio_url_write', json_encode (a:url))
 let l:my_object = json_decode (l:dstr)
 return l:my_object
endfun
