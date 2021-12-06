# dnnet

- **Remote** and local file reader.
- **Remote** and local file writer.

## Use

* In the dnnent file there are functions like dnnet.read(url,opts) and dnnet.write(url,opts) were
url must be string and opts object of type {}.
``` vimscript
" For Reading.
:call dnnet.read("ftp://hostname/path_to_file", {"user_name": "user", "user_password": "password"})
" For writing.
:call dnnet.write("ftp://hostname/path_to_file", {"user_name": "user", "user_password": "password"})
```
