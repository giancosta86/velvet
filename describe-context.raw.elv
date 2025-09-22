use str
use ./assertions
use ./describe-context
use ./describe-result
use ./outcomes
use ./raw

raw:suite 'Testing a describe context' { |test~|
  fn expect-simplified-describe-result { |describe-context expected-result|
    $describe-context[to-result] |
      describe-result:simplify (all) |
      assertions:should-be $expected-result
  }

  test 'Creating empty root' {
    var root = (describe-context:create)

    expect-simplified-describe-result $root [
      &test-results=[&]
      &sub-results=[&]
    ]
  }

  test 'Creating a new sub-context' {
    var root = (describe-context:create)

    $root[ensure-sub-context] Alpha

    expect-simplified-describe-result $root [
      &test-results=[&]
      &sub-results=[
        &Alpha=[
          &test-results=[&]
          &sub-results=[&]
        ]
      ]
    ]
  }

  test 'Ensuring an existing sub-context' {
    var root = (describe-context:create)

    range 0 3 | each { |_|
      $root[ensure-sub-context] Alpha
    }

    expect-simplified-describe-result $root [
      &test-results=[&]
      &sub-results=[
        &Alpha=[
          &test-results=[&]
          &sub-results=[&]
        ]
      ]
    ]
  }

  test 'Running a passing test' {
    var root = (describe-context:create)

    var test-result = (
      $root[run-test] T-OK {
        echo Wiii!
      }
    )

    put $test-result |
      assertions:should-be [
        &outcome=$outcomes:passed
        &output="Wiii!\n"
        &exception-log=$nil
      ]

    expect-simplified-describe-result $root [
      &test-results=[
        &T-OK=[
          &output="Wiii!\n"
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
        echo Hello
        fail Dodo
      }
    )

    put $test-result |
      dissoc (all) exception-log |
      assertions:should-be [
        &outcome=$outcomes:failed
        &output="Hello\n"
      ]

    put $test-result[exception-log] |
      eq (all) $nil |
      assertions:should-be $false

    expect-simplified-describe-result $root [
      &test-results=[
        &T-FAIL=[
          &output="Hello\n"
          &outcome=$outcomes:failed
        ]
      ]
      &sub-results=[&]
    ]
  }

  test 'Running a test with multiple output lines' {
    var root = (describe-context:create)

    $root[run-test] T-OK {
      echo Cip
      echo Ciop
    }

    expect-simplified-describe-result $root [
      &test-results=[
        &T-OK=[
          &output="Cip\nCiop\n"
          &outcome=$outcomes:passed
        ]
      ]
      &sub-results=[&]
    ]
  }

  test 'Running a test with both stdout and stderr' {
    var root = (describe-context:create)

    $root[run-test] T-OK {
      echo Cip
      echo Ciop >&2
    }

    expect-simplified-describe-result $root [
      &test-results=[
        &T-OK=[
          &output="Cip\nCiop\n"
          &outcome=$outcomes:passed
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
      echo Hello 1
      fail Dodo1
    }

    $root[run-test] 'T-OK 2' {
      echo Wiii 2!
    }

    $root[run-test] 'T-FAIL 2' {
      echo Hello 2
      fail Dodo2
    }

    $root[run-test] 'T-OK 3' {
      echo Wiii 3!
    }

    expect-simplified-describe-result $root [
      &sub-results=[&]
      &test-results=[
        &'T-FAIL 1'=[
          &outcome=$outcomes:failed
          &output="Hello 1\n"
        ]
        &'T-FAIL 2'=[
          &outcome=$outcomes:failed
          &output="Hello 2\n"
        ]
        &'T-OK 1'=[
          &outcome=$outcomes:passed
          &output="Wiii 1!\n"
        ]
        &'T-OK 2'=[
          &outcome=$outcomes:passed
          &output="Wiii 2!\n"
        ]
        &'T-OK 3'=[
          &outcome=$outcomes:passed
          &output="Wiii 3!\n"
        ]
      ]
    ]
  }

  test 'Converting to describe result with test tree' {
    var root = (describe-context:create)
    var alpha = ($root[ensure-sub-context] alpha)
    var beta = ($alpha[ensure-sub-context] beta)

    $alpha[run-test] alpha-test {
      echo Hello!
    }

    $beta[run-test] beta-test {
      echo World!
    }

    expect-simplified-describe-result $root [
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

  test 'Running test with the same name' {
    var root = (describe-context:create)

    $root[run-test] 'T-OK' {
      echo Wiii!
    }

    $root[run-test] 'T-OK' {
      echo Wiii!
    }

    var describe-result = ($root[to-result])

    describe-result:simplify $describe-result |
      assertions:should-be [
        &sub-results=  [&]
        &test-results= [
          &T-OK=       [
            &outcome=  F
            &output=   ''
            ]
          ]
        ]

    str:contains $describe-result[test-results][T-OK][exception-log] DUPLICATED |
      assertions:should-be $true
  }
}