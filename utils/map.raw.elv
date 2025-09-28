use ./assertion
use ./map
use ./raw

raw:suite 'Mapping a map' { |test~|
  test 'With empty map' {
    map:map [&] { |key value|
      put [(+ $key 90) (+ $value 80)]
    } |
      eq (all) [&] |
      assertion:assert (all)
  }

  test 'With non-empty map' {
    map:map [&90=Alpha &18=Beta] { |key value|
      put [(+ $key 3) $value''$value]
    } |
      eq (all) [
        &(num 93)=AlphaAlpha
        &(num 21)=BetaBeta
      ] |
      assertion:assert (all)
  }
}