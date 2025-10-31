use file
use os

fn temp-file-path {
  var temp-file = (os:temp-file)
  file:close $temp-file

  put $temp-file[name]
}
