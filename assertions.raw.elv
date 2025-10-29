use ./assertions
use ./utils/assertion
use ./utils/exception
use ./utils/raw

fn with-strictness-determiner { |&strict=$false message|
  var strictness-prefix

  if $strict {
    set strictness-prefix = 'strict '
  } else {
    set strictness-prefix = ''
  }

  put $strictness-prefix''$message
}

fn expect-should-be-failure { |&strict=$false expected actual-block|
  exception:throws {
    $actual-block |
      only-values |
      assertions:should-be &strict=$strict $expected
  } |
    exception:get-fail-content |
    eq (all) (with-strictness-determiner &strict=$strict 'should-be assertion failed') |
    assertion:assert (all)
}

fn expect-should-not-be-failure { |&strict=$false expected actual-block|
  exception:throws {
    $actual-block |
      only-values |
      assertions:should-not-be &strict=$strict $expected
  } |
    exception:get-fail-content |
    eq (all) (with-strictness-determiner &strict=$strict 'should-not-be assertion failed') |
    assertion:assert (all)
}

raw:suite 'Assertions: should-be (strict)' { |test~|
  test 'Equal strings' {
    put Alpha |
      assertions:should-be &strict Alpha
  }

  test 'Different strings' {
    expect-should-be-failure &strict Beta {
      put Alpha
    }
  }

  test 'Equal numbers' {
    put (num 90) |
      assertions:should-be &strict (num 90)
  }

  test 'String and number denoting the same value' {
    expect-should-be-failure &strict (num 90) {
      put 90
    }
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
      assertions:should-be Alpha
  }

  test 'Different strings' {
    expect-should-be-failure Beta {
      put Alpha
    }
  }

  test 'String and number having same value' {
    put 90 |
      assertions:should-be (num 90)
  }
}

raw:suite 'Assertions: should-not-be (strict)' { |test~|
  test 'Equal strings' {
    expect-should-not-be-failure &strict Alpha {
      put Alpha
    }
  }

  test 'Different strings' {
    put Alpha |
      assertions:should-not-be &strict Beta
  }

  test 'Equal numbers' {
    expect-should-not-be-failure &strict (num 90) {
      put (num 90)
    }
  }

  test 'String and number denoting the same value' {
    put 90 |
      assertions:should-not-be &strict (num 90)
  }
}

raw:suite 'Assertions: should-not-be (non-strict)' { |test~|
  test 'Equal strings' {
    expect-should-not-be-failure Alpha {
      put Alpha
    }
  }

  test 'Different strings' {
    put Alpha |
      assertions:should-not-be Beta
  }

  test 'String and number having same value' {
    expect-should-not-be-failure (num 90) {
      put 90
    }
  }

  test 'Different booleans' {
    put $false |
      assertions:should-not-be $true

    put $true |
      assertions:should-not-be $false
  }

  test 'Equal multi-level lists' {
    var test-list = [Alpha [Beta [Gamma Delta] Epsilon] Zeta Eta Theta]

    expect-should-not-be-failure $test-list {
      put $test-list
    }
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

    expect-should-not-be-failure $test-map {
      put $test-map
    }
  }
}

raw:suite 'Assertions: fail-test' { |test~|
  test 'Raising a test failure' {
    exception:throws {
      assertions:fail-test
    } |
      exception:get-fail-content |
      assertions:should-be 'TEST SET TO FAIL'
  }
}