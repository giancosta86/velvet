use str
use ./assertions
use ./outcomes
use ./utils/command
use ./utils/raw
use ./test-result

raw:suite 'Test result detection' { |test~|
  test 'Applied to test result' {
    test-result:is [
      &output=""
      &exception-log=$nil
    ] |
      assertions:should-be $true
  }

  test 'Applied to section' {
    test-result:is [
      &test-results=[&]
      &sub-sections=[&]
    ] |
      assertions:should-be $false
  }
}

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

raw:suite 'Duplicated test result' { |test~|
  test 'Creation' {
    var test-result = (test-result:create-for-duplicated)

    test-result:simplify $test-result |
      assertions:should-be [
        &outcome=$outcomes:failed
        &output=''
      ]

    str:contains $test-result[exception-log] DUPLICATED |
      assertions:should-be $true
  }
}