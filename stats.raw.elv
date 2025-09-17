use ./assertions
use ./raw
use ./stats

raw:suite 'Stats' { |test~|
  test 'Creation' {
    stats:create [
      &passed=9
      &failed=3
    ] |
      assertions:should-be [
        &failed=3
        &passed=9
        &total=12
      ]
  }

  test 'Merging' {
    var left = (stats:create [
      &passed=3
      &failed=5
    ])
    var right = (stats:create [
      &passed=7
      &failed=11
    ])

    stats:merge $left $right |
      assertions:should-be [
        &passed=10
        &failed=16
        &total=26
      ]
  }
}