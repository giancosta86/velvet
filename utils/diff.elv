use os
use ./fs

fn diff { |&throw=$false left right|
  var left-path = (fs:temp-file-path)
  var right-path = (fs:temp-file-path)

  var exception = $nil

  try {
    print $left > $left-path
    print $right > $right-path

    (external diff) --color=always -u $left-path $right-path
  } catch e {
    set exception = $e
  } finally {
    os:remove-all $left-path
    os:remove-all $right-path
  }

  if (and $exception $throw) {
    fail $e
  }
}