use ./assertions
use ./utils/assertion
use ./utils/exception
use ./utils/raw

raw:suite 'Assertions: expect-crash' { |test~|
  test 'When no exception is thrown' {
    try {
      assertions:expect-crash {
        echo Wiii!
        echo Wiii2! >&2
        put 90
      }
    } catch e {
      exception:get-fail-message $e |
        assertion:assert (eq (all) 'The given code block did not fail!')
    }
  }

  test 'When there is an exception' {
    assertions:expect-crash {
      echo Wooo!
      echo Wooo2! >&2
      put 90
      fail DODO
    } |
      exception:get-fail-message (all) |
      assertion:assert (eq (all) DODO)
  }
}

raw:suite 'Assertions: should-be (strict)' { |test~|
  test 'Equal strings' {
    put Alpha |
      assertions:should-be &strict Alpha
  }

  test 'Different strings' {
    assertions:expect-crash {
      put Alpha |
        assertions:should-be &strict Beta
    } |
      exception:get-fail-message (all) |
      assertion:assert (eq (all) 'strict should-be assertion failed')
  }

  test 'Equal numbers' {
    put (num 90) |
      assertions:should-be &strict (num 90)
  }

  test 'String and number denoting the same value' {
    assertions:expect-crash {
      put 90 |
        assertions:should-be &strict (num 90)
    } |
      exception:get-fail-message (all) |
      assertion:assert (eq (all) 'strict should-be assertion failed')
  }

  test 'Equal booleans' {
    put $false |
      assertions:should-be &strict $false

    put $true |
      assertions:should-be &strict $true
  }

  test 'Equal multi-level lists' {
    var test-list = [Alpha [Beta [Gamma Delta] Epsilon] Zeta Eta Theta]

    put $test-list |
      assertions:should-be &strict $test-list
  }

  test 'Equal multi-level maps' {
    var test-map = [
      &alpha=90
      &beta=92
      &gamma=[
        &delta=95
        &epsilon=[
          &zeta=98
        ]
        &eta=99
      ]
    ]

    put $test-map |
      assertions:should-be &strict $test-map
  }
}

raw:suite 'Assertions: should-be (non-strict)' { |test~|
  test 'Equal strings' {
    put Alpha |
      assertions:should-be &strict=$false Alpha
  }

  test 'Different strings' {
    assertions:expect-crash {
      put Alpha |
        assertions:should-be &strict=$false Beta
    } |
      exception:get-fail-message (all) |
      assertion:assert (eq (all) 'should-be assertion failed')
  }

  test 'String and number having same value' {
    put 90 |
      assertions:should-be &strict=$false (num 90)
  }
}

raw:suite 'Assertions: fail-test' { |test~|
  test 'Raising a test failure' {
    assertions:expect-crash {
      assertions:fail-test
    } |
      exception:get-fail-message (all) |
      assertions:should-be 'TEST SET TO FAIL'
  }
}