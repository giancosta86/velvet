use str
use ./assertions
use ./outcomes
use ./utils/command
use ./utils/raw
use ./test-result

raw:suite 'Test result from capture result' { |test~|
  test 'For passing block' {
    command:capture {
      echo Wiii!
      echo Wiii2! >&2
      put 90
    } |
      test-result:from-capture-result (all) |
      assertions:should-be [
        &outcome=$outcomes:passed
        &output="Wiii!\nWiii2!\n"
        &exception-log=$nil
      ]
  }

  test 'For crashing block' {
    var test-result = (
      command:capture {
        echo Wiii!
        echo Wiii2! >&2
        put 90
        fail DODUS
      } |
        test-result:from-capture-result (all)
    )

    put $test-result[outcome] |
      assertions:should-be $outcomes:failed

    put $test-result[output] |
      assertions:should-be "Wiii!\nWiii2!\n"

    put $test-result[exception-log] |
      assertions:should-not-be &strict $nil
  }

  test 'Removing clockwork from exception log' {
    command:capture {
      echo Wiii!
      echo Wiii2! >&2
      put 90
      fail DODUS
    } |
      test-result:from-capture-result (all) |
      str:contains (all)[exception-log] '/velvet/utils/command.elv:' |
      assertions:should-be $false
  }

  test 'For block with return keyword' {
    command:capture {
      echo Wiii!
      echo Wiii2! >&2
      put 90

      return

      echo Not printed

      fail 'HAVING NO EFFECT'
    } |
      test-result:from-capture-result (all) |
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