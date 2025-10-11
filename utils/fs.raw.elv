use os
use ./assertion
use ./fs
use ./raw

raw:suite 'Temp file path' { |test~|
  test 'Is a string' {
    var temp-file-path = (fs:temp-file-path)
    defer { os:remove $temp-file-path }

    put $temp-file-path |
      kind-of (all) |
      eq (all) string |
      assertion:assert (all)
  }

  test 'Exists' {
    var temp-file-path = (fs:temp-file-path)
    defer { os:remove $temp-file-path }

    put $temp-file-path |
      os:exists (all) |
      assertion:assert (all)
  }
}