use os
use ./assertion
use ./fs
use ./raw

raw:suite 'Temp path' { |test~|
  test 'Is a string' {
    fs:temp-file-path |
      kind-of (all) |
      eq (all) string |
      assertion:assert (all)
  }

  test 'Exists' {
    fs:temp-file-path |
      os:exists (all) |
      assertion:assert (all)
  }
}