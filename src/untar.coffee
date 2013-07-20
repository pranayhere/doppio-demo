"use strict"

root = this


root.untar = (bytes, cb, done_cb) ->
  next_file = ->
    [path,body] = shift_file(bytes)
    percent = bytes.pos() / bytes.size()
    cb percent, path, body
    if bytes.peek() != 0
      asyncExecute next_file
    else
      done_cb?()
  asyncExecute next_file

shift_file = (bytes) ->
  header = bytes.read(512)
  fname = util.bytes2str header[0...100], true
  size = octal2num header[124...124+11]
  prefix = util.bytes2str header[345...345+155], true
  fullname = if prefix then "#{prefix}/#{fname}" else fname
  padding = Math.ceil(size/512)*512 - size
  file = bytes.slice(size)
  bytes.skip padding
  [fullname, file]

octal2num = (bytes) ->
  num = 0
  msd = bytes.length - 1
  for b, idx in bytes
    digit = parseInt String.fromCharCode b
    num += digit * Math.pow 8, (msd - idx)
  num

# modern browsers slow the event loop when tab is not in focus,
# so don't give up control! but guard against stack overflows, too.
nonAsyncCount = 0
asyncExecute = (fn) ->
  if (document? and (document.hidden or document.mozHidden or
      document.webkitHidden or document.msHidden) and
      nonAsyncCount++ < 10000)
    fn()
  else
    nonAsyncCount = 0
    setImmediate fn
