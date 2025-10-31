use os
use ./assertion
use ./fs
use ./raw

raw:suite 'Temp file path' { |test~|
  test 'Is a string' {
    var temp-file-path = (fs:temp-file-path)
    defer { os:remove $temp-file-path }

    kind-of $temp-file-path |
      eq (all) string |
      assertion:assert (all)
  }

  test 'Exists' {
    var temp-file-path = (fs:temp-file-path)
    defer { os:remove $temp-file-path }

    os:exists $temp-file-path |
      assertion:assert (all)
  }
}