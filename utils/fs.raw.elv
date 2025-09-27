use os
use ./assertion
use ./fs
use ./raw

raw:suite 'Temp path creation' { |test~|
  test 'Type' {
    var temp-path = (fs:temp-file-path)

    kind-of $temp-path |
      eq (all) string |
      assertion:assert (all)
  }

  test 'Existence' {
    var temp-path = (fs:temp-file-path)

    os:exists $temp-path |
      assertion:assert (all)
  }
}