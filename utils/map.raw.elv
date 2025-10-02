use ./assertion
use ./map
use ./raw

raw:suite 'Filter-mapping a map' { |test~|
  test 'With empty map' {
    map:filter-map [&] { |key value|
      put [(+ $key 90) (+ $value 80)]
    } |
      eq (all) [&] |
      assertion:assert (all)
  }

  test 'With non-empty map' {
    map:filter-map [&90=Alpha &18=Beta] { |key value|
      put [(+ $key 3) $value''$value]
    } |
      eq (all) [
        &(num 93)=AlphaAlpha
        &(num 21)=BetaBeta
      ] |
      assertion:assert (all)
  }

  test 'With filtering' {
    map:filter-map [&90=Alpha &18=Beta &72=Gamma &32=Delta] { |key value|
      if (< $key 50) {
        put [$key $value]
      } else {
        put $nil
      }
    } |
      eq (all) [&18=Beta &32=Delta] |
      assertion:assert (all)
  }
}