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

    $root[ensure-sub-context] 'Alpha'

    var result-context = ($root[to-result-context])

    assert (hash-set:equals $result-context[sub-contexts] [Alpha])
  }

  test 'Ensuring an existing sub-context' {
    var root = (describe-context:create)

    range 0 5 | each { |_|
      $root[ensure-sub-context] 'Alpha'
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

    assert (eq $result-context [
      &tests=[
        &T_OK=[
          &output=Wiiii!
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
          &output=Hello
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
          &output='Hello 1'
        ]
        &'T_FAIL 2'=[
          &outcome=failed
          &output='Hello 2'
        ]
        &'T_OK 1'=[
          &outcome=passed
          &output='Wiiii 1!'
        ]
        &'T_OK 2'=[
          &outcome=passed
          &output='Wiiii 2!'
        ]
        &'T_OK 3'=[
          &outcome=passed
          &output='Wiiii 3!'
        ]
      ]
    ])
  }
}