use str
use ./assertions
use ./outcomes
use ./utils/raw
use ./test-result

raw:suite 'Test result from block' { |test~|
  test 'For passing block' {
    test-result:from-block {
      echo Wiii!
      echo Wiii2! >&2
      put 90
    } |
      assertions:should-be [
        &outcome=$outcomes:passed
        &output="Wiii!\nWiii2!\n"
        &exception-log=$nil
      ]
  }

  test 'For crashing block' {
    var test-result = (
      test-result:from-block {
        echo Wiii!
        echo Wiii2! >&2
        put 90
        fail DODUS
      }
     )

    put $test-result[outcome] |
      assertions:should-be $outcomes:failed

    put $test-result[output] |
      assertions:should-be "Wiii!\nWiii2!\n"

    put $test-result[exception-log] |
      assertions:should-not-be &strict $nil
  }

  test 'For block with return keyword' {
    test-result:from-block {
      echo Wiii!
      echo Wiii2! >&2
      put 90

      return

      echo Not printed

      fail 'HAVING NO EFFECT'
    } |
      assertions:should-be [
        &outcome=$outcomes:passed
        &output="Wiii!\nWiii2!\n"
        &exception-log=$nil
      ]
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