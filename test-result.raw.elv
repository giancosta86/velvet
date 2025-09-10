use ./assertions
use ./outcomes
use ./raw
use ./test-result

raw:suite 'Test result' { |test~|
  test 'Simplification for passing test' {
    test-result:simplify [
      &output="Lorem ipsum\n"
      &status=$ok
      &outcome=$outcomes:passed
    ] |
      assertions:should-be [
        &output="Lorem ipsum\n"
        &outcome=$outcomes:passed
      ]
  }

  test 'Simplification for failing test' {
    test-result:simplify [
      &output="Lorem ipsum\n"
      &status=?(fail DODO)
      &outcome=$outcomes:failed
    ] |
      assertions:should-be [
        &output="Lorem ipsum\n"
        &outcome=$outcomes:failed
      ]
  }
}