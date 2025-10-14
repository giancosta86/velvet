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

  test 'Adding a passing test' {
    var root = (describe-context:create)

    var test-result = (
      test-result:from-block {
        echo Wiii!
        echo Wiii2! >&2
        put 90
      }
    )

    $root[add-test-result] T-OK $test-result

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

  test 'Adding a failing test' {
    var root = (describe-context:create)

    var test-result = (
      test-result:from-block {
        echo Wooo
        echo Wooo2 >&2
        put 90
        fail Dodo
      }
    )

    $root[add-test-result] T-FAIL $test-result

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

  test 'Adding passing and failing tests' {
    var root = (describe-context:create)

    var t-ok-1 = (
      test-result:from-block {
        echo Wiii 1!
      }
    )
    $root[add-test-result] 'T-OK 1' $t-ok-1

    var t-fail-1 = (
      test-result:from-block {
        echo Wooo 1
        fail DODO1
      }
    )
    $root[add-test-result] 'T-FAIL 1' $t-fail-1

    var t-ok-2 = (
      test-result:from-block {
        echo Wiii 2! >&2
      }
    )
    $root[add-test-result] 'T-OK 2' $t-ok-2

    var t-fail-2 = (
      test-result:from-block {
        echo Wooo 2
        fail Dodo2
        echo NEVER PRINTED
      }
    )
    $root[add-test-result] 'T-FAIL 2' $t-fail-2

    var t-ok-3 = (
      test-result:from-block {
        echo Wiii 3!
      }
    )
    $root[add-test-result] 'T-OK 3' $t-ok-3

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

  test 'Adding test with the same name' {
    var root = (describe-context:create)

    var test-result = (
      test-result:from-block {
        echo Wiii!
      }
    )

    put $test-result[outcome] |
      assertions:should-be $outcomes:passed

    $root[add-test-result] T-DUP $test-result

    $root[add-test-result] T-DUP $test-result

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

  test 'Adding multi-level test tree' {
    var root = (describe-context:create)
    var alpha = ($root[ensure-sub-context] alpha)
    var beta = ($alpha[ensure-sub-context] beta)

    var alpha-result = (
      test-result:from-block {
        echo Hello!
      }
    )
    $alpha[add-test-result] alpha-test $alpha-result

    var beta-result = (
      test-result:from-block {
        echo World!
      }
    )
    $beta[add-test-result] beta-test $beta-result

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