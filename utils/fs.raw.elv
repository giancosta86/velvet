use os
use ./assertion
use ./fs
use ./raw

raw:suite 'Temp path creation' { |test~|
  test 'Type' {
    fs:temp-file-path |
      kind-of (all) |
      eq (all) string |
      assertion:assert (all)
  }

  test 'Existence' {
    fs:temp-file-path |
      os:exists (all) |
      assertion:assert (all)
  }
}