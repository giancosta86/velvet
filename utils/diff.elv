use os
use ./fs

fn diff { |left right|
  var left-path = (fs:temp-file-path)
  var right-path = (fs:temp-file-path)

  try {
    print $left > $left-path
    print $right > $right-path

    (external diff) --color=always -u $left-path $right-path
  } catch e {
    # Just hide the exception
  } finally {
    os:remove-all $left-path
    os:remove-all $right-path
  }
}