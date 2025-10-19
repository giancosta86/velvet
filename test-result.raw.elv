use ./assertions
use ./outcomes
use ./utils/raw
use ./test-result

raw:suite 'Test result simplification' { |test~|
  test 'For passing test' {
    test-result:simplify [
      &output="Lorem ipsum\n"
      &outcome=$outcomes:passed
      &exception-log=$nil
    ] |
      assertions:should-be [
        &output="Lorem ipsum\n"
        &outcome=$outcomes:passed
      ]
  }

  test 'For failing test' {
    test-result:simplify [
      &output="Lorem ipsum\n"
      &outcome=$outcomes:failed
      &exception-log=(show ?(fail DODO) | slurp)
    ] |
      assertions:should-be [
        &output="Lorem ipsum\n"
        &outcome=$outcomes:failed
      ]
  }
}

raw:suite 'Duplicate test result' { |test~|
  test 'Creation' {
    var test-result = (test-result:create-for-duplicate)

    test-result:simplify $test-result |
      assertions:should-be [
        &outcome=$outcomes:failed
        &output=''
      ]

    put $test-result[exception-log] |
      assertions:should-be 'DUPLICATE TEST!'
  }
}