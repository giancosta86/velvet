use github.com/giancosta86/aurora-elvish/command
use github.com/giancosta86/aurora-elvish/exception
use github.com/giancosta86/aurora-elvish/map
use ./assertions
use ./describe-context
use ./raw

raw:suite 'Testing a describe context' { |test~|
  fn simplify-test { |test|
    put [
      &output=$test[output]
      &outcome=$test[outcome]
    ]
  }

  fn simplify-result-context { |result-context|
    var simplified-tests = (
      map:map $result-context[tests] { |key test|
        put [$key (simplify-test $test)]
      }
    )

    var simplified-sub-contexts = (
      map:map $result-context[sub-contexts] { |key sub-context|
        put [$key (simplify-result-context $sub-context)]
      }
    )

    put [
      &tests=$simplified-tests
      &sub-contexts=$simplified-sub-contexts
    ]
  }

  fn expect-simplified-result-context { |actual-describe-context simplified-expected-context|
    var simplified-actual-context = (
      simplify-result-context ($actual-describe-context[to-result-context])
    )

    pprint $simplified-actual-context

    put $simplified-actual-context |
      assertions:should-be $simplified-expected-context
  }

  test 'Creating empty root' {
    var root = (describe-context:create)

    expect-simplified-result-context $root [
      &tests=[&]
      &sub-contexts=[&]
    ]
  }

  test 'Creating a new sub-context' {
    var root = (describe-context:create)

    $root[ensure-sub-context] Alpha

    expect-simplified-result-context $root [
      &tests=[&]
      &sub-contexts=[
        &Alpha=[
          &tests=[&]
          &sub-contexts=[&]
        ]
      ]
    ]
  }

  test 'Ensuring an existing sub-context' {
    var root = (describe-context:create)

    range 0 3 | each { |_|
      $root[ensure-sub-context] Alpha
    }

    expect-simplified-result-context $root [
      &tests=[&]
      &sub-contexts=[
        &Alpha=[
          &tests=[&]
          &sub-contexts=[&]
        ]
      ]
    ]
  }

  test 'Running a successful test' {
    var root = (describe-context:create)

    $root[run-test] T_OK {
      echo Wiiii!
    }

    expect-simplified-result-context $root [
      &tests=[
        &T_OK=[
          &output="Wiiii!\n"
          &outcome=passed
        ]
      ]
      &sub-contexts=[&]
    ]
  }

  test 'Running a failed test' {
    var root = (describe-context:create)

    $root[run-test] T_FAIL {
      echo Hello
      fail Dodo
    }

    expect-simplified-result-context $root [
      &tests=[
        &T_FAIL=[
          &output="Hello\n"
          &outcome=failed
        ]
      ]
      &sub-contexts=[&]
    ]
  }

  test 'Running a test with multiple output lines' {
    var root = (describe-context:create)

    $root[run-test] T_OK {
      echo Cip
      echo Ciop
    }

    expect-simplified-result-context $root [
      &tests=[
        &T_OK=[
          &output="Cip\nCiop\n"
          &outcome=passed
        ]
      ]
      &sub-contexts=[&]
    ]
  }

  test 'Running a test with both stdout and stderr' {
    var root = (describe-context:create)

    $root[run-test] T_OK {
      echo Cip
      echo Ciop >&2
    }

    expect-simplified-result-context $root [
      &tests=[
        &T_OK=[
          &output="Cip\nCiop\n"
          &outcome=passed
        ]
      ]
      &sub-contexts=[&]
    ]
  }

  test 'Running successful and failed tests' {
    var root = (describe-context:create)

    $root[run-test] 'T_OK 1' {
      echo Wiiii 1!
    }

    $root[run-test] 'T_FAIL 1' {
      echo Hello 1
      fail Dodo1
    }

    $root[run-test] 'T_OK 2' {
      echo Wiiii 2!
    }

    $root[run-test] 'T_FAIL 2' {
      echo Hello 2
      fail Dodo2
    }

    $root[run-test] 'T_OK 3' {
      echo Wiiii 3!
    }

    expect-simplified-result-context $root [
      &sub-contexts=[&]
      &tests=[
        &'T_FAIL 1'=[
          &outcome=failed
          &output="Hello 1\n"
        ]
        &'T_FAIL 2'=[
          &outcome=failed
          &output="Hello 2\n"
        ]
        &'T_OK 1'=[
          &outcome=passed
          &output="Wiiii 1!\n"
        ]
        &'T_OK 2'=[
          &outcome=passed
          &output="Wiiii 2!\n"
        ]
        &'T_OK 3'=[
          &outcome=passed
          &output="Wiiii 3!\n"
        ]
      ]
    ]
  }

  test 'Converting to result context with test tree' {
    var root = (describe-context:create)
    var alpha = ($root[ensure-sub-context] alpha)
    var beta = ($alpha[ensure-sub-context] beta)

    $alpha[run-test] alpha-test {
      echo Hello!
    }

    $beta[run-test] beta-test {
      echo World!
    }

    expect-simplified-result-context $root [
      &tests=[&]
      &sub-contexts=[
        &alpha=[
          &tests=[
            &alpha-test=[
              &outcome=passed
              &output="Hello!\n"
            ]
          ]

          &sub-contexts=[
            &beta=[
              &tests=[
                &beta-test=[
                  &outcome=passed
                  &output="World!\n"
                ]
              ]
              &sub-contexts=[&]
            ]
          ]
        ]
      ]
    ]
  }

  test 'Running test with the same name' {
    var root = (describe-context:create)

    $root[run-test] 'T_OK' {
      echo Wiiii!
    }

    var capture-result = (
      command:capture {
        $root[run-test] 'T_OK' {
          echo Wiiii!
        }
      }
    )

    exception:get-fail-message $capture-result[status] |
      assertions:should-be 'Duplicated test: ''T_OK'''
  }
}