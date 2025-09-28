use ./assertion
use ./raw
use ./string

raw:suite 'Minimal string' { |test~|
  test 'With string' {
    ==s (string:get-minimal Dodo) Dodo |
      assertion:assert (all)
  }

  test 'With number' {
    ==s (string:get-minimal (num 90)) 90 |
      assertion:assert (all)
  }

  test 'With bool' {
    ==s (string:get-minimal $false) '$false' |
      assertion:assert (all)
  }

  test 'With list' {
    ==s (string:get-minimal [A (num 90) (num 92)]) '[A 90 92]' |
      assertion:assert (all)
  }

  test 'With map' {
    ==s (string:get-minimal [&(num 90)=(num 92)]) '[&90=92]' |
      assertion:assert (all)
  }
}