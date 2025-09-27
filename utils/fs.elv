use file
use os

fn temp-file-path { |&dir='' @pattern|
  var temp-file = (os:temp-file &dir=$dir $@pattern)
  file:close $temp-file

  put $temp-file[name]
}
