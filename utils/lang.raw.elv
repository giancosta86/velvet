use ./assertion
use ./lang
use ./raw

raw:suite 'is-function test' { |test~|
  test 'on number' {
    lang:is-function (num 90) |
      not (all) |
      assertion:assert (all)
  }

  test 'on function' {
    lang:is-function { |x| + $x 1 } |
      assertion:assert (all)
  }
}