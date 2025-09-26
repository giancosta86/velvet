use ./assertions
use ./utils/assertion
use ./utils/raw
use ./utils/exception

raw:suite 'Assertions: expect-crash' { |test~|
  test 'When there is no exception' {
    try {
      assertions:expect-crash {
        echo 'Wiii!'
      }
    } catch e {
      var message = (exception:get-fail-message $e)

      assertion:assert (==s $message 'The given code block did not fail!')
    }
  }

  test 'When there is an exception' {
    var ex = (
      assertions:expect-crash {
        fail 'Dodo'
      }
    )

    var message = (
      exception:get-fail-message $ex
    )

    assertion:assert (eq $message 'Dodo')
  }
}

raw:suite 'Assertions: should-be' { |test~|
  test 'Expected string, actual same string, strict equal' {
    put Alpha |
      assertions:should-be &strict=$true Alpha
  }

  test 'Expected string, actual different string, strict equal' {
    var message = (
      assertions:expect-crash {
        put Alpha |
          assertions:should-be &strict=$true Beta
      } |
        exception:get-fail-message (all)
    )

    assertion:assert (eq $message 'strict should-be assertion failed')
  }

  test 'Expected string, actual same-valued number, strict equal' {
    var message = (
      assertions:expect-crash {
        put 90 |
          assertions:should-be &strict=$true (num 90)
      } |
        exception:get-fail-message (all)
    )

    assertion:assert (eq $message 'strict should-be assertion failed')
  }

  test 'Expected string, actual same string, non-strict equal' {
    put Alpha |
      assertions:should-be &strict=$false Alpha
  }

  test 'Expected string, actual different string, non-strict equal' {
    var message = (
      assertions:expect-crash {
        put Alpha |
          assertions:should-be &strict=$false Beta
      } |
        exception:get-fail-message (all)
    )

    assertion:assert (eq $message 'should-be assertion failed')
  }

  test 'Expected string, actual same-valued number, non-strict equal' {
    put 90 |
      assertions:should-be &strict=$false (num 90)
  }

  test 'Expected number, actual same number, strict equal' {
    put (num 90) |
      assertions:should-be &strict=$true (num 90)
  }

  test 'Expected boolean, actual value, strict equal' {
    put $false |
      assertions:should-be &strict=$true $false

    put $true |
      assertions:should-be &strict=$true $true
  }

  test 'Expected multi-level list, actual same list, strict equal' {
    var test-list = [Alpha [Beta [Gamma Delta] Epsilon] Zeta Eta Theta]

    put $test-list |
      assertions:should-be &strict=$true $test-list
  }

  test 'Expected multi-level map, actual same map, strict equal' {
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
      assertions:should-be &strict=$true $test-map
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