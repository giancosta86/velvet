use str
use ./assertions
use ./describe-context
use ./describe-result
use ./outcomes
use ./test-result
use ./utils/raw

raw:suite 'Describe context' { |test~|
  fn expect-simplified-result { |describe-context expected-result|
    $describe-context[to-result] |
      describe-result:simplify (all) |
      assertions:should-be $expected-result
  }

  test 'Creating empty root' {
    var root = (describe-context:create)

    expect-simplified-result $root [
      &test-results=[&]
      &sub-results=[&]
    ]
  }

  test 'Creating a new empty sub-context - that gets pruned' {
    var root = (describe-context:create)

    $root[ensure-sub-context] Alpha

    expect-simplified-result $root [
      &test-results=[&]
      &sub-results=[&]
    ]
  }

  test 'Ensuring an existing sub-context - that still gets pruned' {
    var root = (describe-context:create)

    range 0 3 | each { |_|
      $root[ensure-sub-context] Alpha
    }

    expect-simplified-result $root [
      &test-results=[&]
      &sub-results=[&]
    ]
  }

  test 'Ensuring multi-level sub-contexts - that all get pruned' {
    var root = (describe-context:create)

    var alpha = ($root[ensure-sub-context] Alpha)

    var beta = ($alpha[ensure-sub-context] Beta)

    var gamma = ($beta[ensure-sub-context] Gamma)

    expect-simplified-result $root [
      &test-results=[&]
      &sub-results=[&]
    ]
  }

  test 'Running a passing test' {
    var root = (describe-context:create)

    var test-result = (
      $root[run-test] T-OK {
        echo Wiii!
        echo Wiii2! >&2
        put 90
      }
    )

    put $test-result |
      assertions:should-be [
        &outcome=$outcomes:passed
        &output="Wiii!\nWiii2!\n"
        &exception-log=$nil
      ]

    expect-simplified-result $root [
      &test-results=[
        &T-OK=[
          &output="Wiii!\nWiii2!\n"
          &outcome=$outcomes:passed
        ]
      ]
      &sub-results=[&]
    ]
  }

  test 'Running a failing test' {
    var root = (describe-context:create)

    var test-result = (
      $root[run-test] T-FAIL {
        echo Wooo
        echo Wooo2 >&2
        put 90
        fail Dodo
      }
    )

    put $test-result |
      test-result:simplify (all) |
      assertions:should-be [
        &outcome=$outcomes:failed
        &output="Wooo\nWooo2\n"
      ]

    put $test-result[exception-log] |
      assertions:should-not-be &strict $nil |

    expect-simplified-result $root [
      &test-results=[
        &T-FAIL=[
          &output="Wooo\nWooo2\n"
          &outcome=$outcomes:failed
        ]
      ]
      &sub-results=[&]
    ]
  }

  test 'Running passing and failing tests' {
    var root = (describe-context:create)

    $root[run-test] 'T-OK 1' {
      echo Wiii 1!
    }

    $root[run-test] 'T-FAIL 1' {
      echo Wooo 1
      fail DODO1
    }

    $root[run-test] 'T-OK 2' {
      echo Wiii 2! >&2
    }

    $root[run-test] 'T-FAIL 2' {
      echo Wooo 2
      fail Dodo2
      echo NEVER PRINTED
    }

    $root[run-test] 'T-OK 3' {
      echo Wiii 3!
    }

    expect-simplified-result $root [
      &sub-results=[&]
      &test-results=[
        &'T-OK 1'=[
          &outcome=$outcomes:passed
          &output="Wiii 1!\n"
        ]

        &'T-FAIL 1'=[
          &outcome=$outcomes:failed
          &output="Wooo 1\n"
        ]

        &'T-OK 2'=[
          &outcome=$outcomes:passed
          &output="Wiii 2!\n"
        ]

        &'T-FAIL 2'=[
          &outcome=$outcomes:failed
          &output="Wooo 2\n"
        ]

        &'T-OK 3'=[
          &outcome=$outcomes:passed
          &output="Wiii 3!\n"
        ]
      ]
    ]
  }

  test 'Running test with the same name' {
    var root = (describe-context:create)

    var passing-block = {
      echo Wiii!
    }

    var first-result = ($root[run-test] T-DUP $passing-block)

    put $first-result[outcome] |
      assertions:should-be $outcomes:passed


    var second-result = ($root[run-test] T-DUP $passing-block)

    put $second-result[outcome] |
      assertions:should-be $outcomes:failed

    str:contains $second-result[exception-log] DUPLICATED |
      assertions:should-be $true


    var describe-result = ($root[to-result])

    describe-result:simplify $describe-result |
      assertions:should-be [
        &test-results=[
          &T-DUP=[
            &output=''
            &outcome=$outcomes:failed
          ]
        ]
        &sub-results=[&]
      ]

    str:contains $describe-result[test-results][T-DUP][exception-log] DUPLICATED |
      assertions:should-be $true
  }

  test 'With multi-level test tree' {
    var root = (describe-context:create)

    var alpha = ($root[ensure-sub-context] alpha)

    $alpha[run-test] alpha-test {
      echo Hello!
    }

    var beta = ($alpha[ensure-sub-context] beta)

    $beta[run-test] beta-test {
      echo World!
    }

    expect-simplified-result $root [
      &test-results=[&]
      &sub-results=[
        &alpha=[
          &test-results=[
            &alpha-test=[
              &outcome=$outcomes:passed
              &output="Hello!\n"
            ]
          ]

          &sub-results=[
            &beta=[
              &test-results=[
                &beta-test=[
                  &outcome=$outcomes:passed
                  &output="World!\n"
                ]
              ]
              &sub-results=[&]
            ]
          ]
        ]
      ]
    ]
  }
}