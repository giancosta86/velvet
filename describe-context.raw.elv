use github.com/giancosta86/aurora-elvish/hash-set
use ./raw
use ./describe-context

raw:suite 'Testing a describe context' { |test~ assert~|
  test 'Creating empty root' {
    var root = (describe-context:create)

    var result-context = ($root[to-result-context])

    assert (eq $result-context[tests] [&])
    assert (eq $result-context[sub-contexts] [&])
  }

  test 'Creating a new sub-context' {
    var root = (describe-context:create)

    $root[ensure-sub-context] Alpha

    var result-context = ($root[to-result-context])

    assert (hash-set:equals $result-context[sub-contexts] [Alpha])
  }

  test 'Ensuring an existing sub-context' {
    var root = (describe-context:create)

    range 0 3 | each { |_|
      $root[ensure-sub-context] Alpha
    }

    var result-context = ($root[to-result-context])

    assert (hash-set:equals $result-context[sub-contexts] [Alpha])
  }

  test 'Running a successful test' {
    var root = (describe-context:create)

    $root[run-test] T_OK {
      echo Wiiii!
    }

    var result-context = ($root[to-result-context])

    pprint $result-context

    assert (eq $result-context [
      &tests=[
        &T_OK=[
          &output="Wiiii!\n"
          &outcome=passed
        ]
      ]
      &sub-contexts= [&]
    ])
  }

  test 'Running a failed test' {
    var root = (describe-context:create)

    $root[run-test] T_FAIL {
      echo Hello
      fail Dodo
    }

    var result-context = ($root[to-result-context])

    assert (eq $result-context [
      &tests=[
        &T_FAIL=[
          &output="Hello\n"
          &outcome=failed
        ]
      ]
      &sub-contexts= [&]
    ])
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

    var result-context = ($root[to-result-context])

    assert (eq $result-context [
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
    ])
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

    var result-context = ($root[to-result-context])

    assert (eq $result-context [
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
              &sub-contexts= [&]
            ]
          ]
        ]
      ]
    ])
  }
}