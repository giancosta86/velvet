use str
use github.com/giancosta86/ethereal/v1/exception
use github.com/giancosta86/ethereal/v1/set
use ./assertions

>> 'Expecting an exception' {
  >> 'when no exception is thrown' {
    try {
      assertions:throws { }

      fail 'No exception was thrown by the expectation!'
    } catch e {
      exception:get-fail-content $e |
        should-be 'The given code block did not fail!'
    }
  }

  >> 'when there is an exception' {
    assertions:throws {
      fail DODO
    } |
      exception:get-fail-content |
      should-be DODO
  }

  >> 'in a pipeline, without arguments' {
    assertions:throws {
      fail CIOP
    } |
      exception:get-fail-content |
      should-be CIOP
  }
}

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
  assertions:throws {
    $actual-block |
      only-values |
      assertions:should-be &strict=$strict $expected
  } |
    exception:get-fail-content |
    should-be (with-strictness-determiner &strict=$strict $assertions:-should-be-error-message)
}

fn expect-should-not-be-failure { |&strict=$false expected actual-block|
  assertions:throws {
    $actual-block |
      only-values |
      assertions:should-not-be &strict=$strict $expected
  } |
    exception:get-fail-content |
    should-be (with-strictness-determiner &strict=$strict 'should-not-be assertion failed')
}

>> 'Assertions: should-be (strict)' {
  >> 'with equal strings' {
    put Alpha |
      assertions:should-be &strict Alpha
  }

  >> 'with different strings' {
    expect-should-be-failure &strict Beta {
      put Alpha
    }
  }

  >> 'with equal numbers' {
    put (num 90) |
      assertions:should-be &strict (num 90)
  }

  >> 'with string and number denoting the same value' {
    expect-should-be-failure &strict (num 90) {
      put 90
    }
  }

  >> 'with equal booleans' {
    put $false |
      assertions:should-be &strict $false

    put $true |
      assertions:should-be &strict $true
  }

  >> 'with equal multi-level lists' {
    var test-list = [Alpha [Beta [Gamma Delta] Epsilon] Zeta Eta Theta]

    put $test-list |
      assertions:should-be &strict $test-list
  }

  >> 'with equal multi-level maps' {
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

>> 'Assertions: should-be (non-strict)' {
  >> 'with equal strings' {
    put Alpha |
      assertions:should-be Alpha
  }

  >> 'with different strings' {
    expect-should-be-failure Beta {
      put Alpha
    }
  }

  >> 'with string and number having same value' {
    put 90 |
      assertions:should-be (num 90)
  }
}

>> 'Assertions: should-not-be (strict)' {
  >> 'with equal strings' {
    expect-should-not-be-failure &strict Alpha {
      put Alpha
    }
  }

  >> 'with different strings' {
    put Alpha |
      assertions:should-not-be &strict Beta
  }

  >> 'with equal numbers' {
    expect-should-not-be-failure &strict (num 90) {
      put (num 90)
    }
  }

  >> 'with string and number denoting the same value' {
    put 90 |
      assertions:should-not-be &strict (num 90)
  }
}

>> 'Assertions: should-not-be (non-strict)' {
  >> 'with equal strings' {
    expect-should-not-be-failure Alpha {
      put Alpha
    }
  }

  >> 'with different strings' {
    put Alpha |
      assertions:should-not-be Beta
  }

  >> 'with string and number having same value' {
    expect-should-not-be-failure (num 90) {
      put 90
    }
  }

  >> 'with different booleans' {
    put $false |
      assertions:should-not-be $true

    put $true |
      assertions:should-not-be $false
  }

  >> 'with equal multi-level lists' {
    var test-list = [Alpha [Beta [Gamma Delta] Epsilon] Zeta Eta Theta]

    expect-should-not-be-failure $test-list {
      put $test-list
    }
  }

  >> 'with equal multi-level maps' {
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

>> 'Assertions: should-emit' {
  >> 'when the argument is not a list' {
    throws {
      {
        put 90
      } |
        assertions:should-emit 90
    } |
      get-fail-content |
      should-be 'The expected argument must be a list of values'
  }

  >> 'when emitting nothing' {
    { } |
      assertions:should-emit []
  }

  >> 'when emitting a string' {
    {
      put 'Hello, world!'
    } |
      assertions:should-emit [
        'Hello, world!'
      ]
  }

  >> 'when emitting a number' {
    >> 'when in string format' {
      {
        put 90
      } |
        assertions:should-emit [
          90
        ]
    }

    >> 'when in different formats' {
      {
        put 90
      } |
        assertions:should-emit [
          (num 90)
        ]
    }
  }

  >> 'when emitting both a string and a number' {
    {
      put Hello
      put 90
    } |
      assertions:should-emit [
        Hello
        90
      ]
  }

  >> 'when emitting via echo' {
    {
      echo Hello
      echo World
    } |
      assertions:should-emit [
        Hello
        World
      ]
  }

  >> 'when enabling strict equality' {
    >> 'when the data type is the same' {
      {
        put 90
      } |
        assertions:should-emit &strict [
          90
        ]
    }

    >> 'when the data type is different' {
      throws {
      {
        put 90
      } |
        assertions:should-emit &strict [
          (num 90)
        ]
    } |
      get-fail-content |
      str:contains (all) 'should-emit assertion failed' |
      should-be $true
    }
  }

  >> 'when the order is wrong' {
    throws {
      {
        put 95
        put 90
        put 98
        put 100
        put 92
      } |
        assertions:should-emit [
          90
          92
          95
          98
          100
        ]
    } |
      get-fail-content |
      str:contains (all) 'should-emit assertion failed' |
      should-be $true
  }

  >> 'when ordering via a key' {
    {
      put 95
      put 90
      put 98
      put 100
      put 92
    } |
      assertions:should-emit &order-key=$num~ [
        90
        92
        95
        98
        100
      ]
  }
}

>> 'Assertions: should-not-emit' {
  >> 'when the argument is not a list' {
    throws {
      {
        put 90
      } |
        assertions:should-not-emit 90
    } |
      get-fail-content |
      should-be 'The argument must be a list of values'
  }

  >> 'when not strict' {
    >> 'when none of the unexpected value is emitted' {
      {
        put Alpha
        put Beta
        put Gamma
      } |
        assertions:should-not-emit [
          90
          Dodo
          $true
        ]
    }

    >> 'when one of the unexpected values is emitted' {
      throws {
        {
          put Alpha
          put Beta
          put Dodo
          put Delta
        } |
          assertions:should-not-emit [
            90
            Dodo
            $true
          ]
      } |
        get-fail-content |
        should-be 'should-not-emit assertion failed'
    }

    >> 'when multiple unexpected values are emitted' {
      try {
        {
          put Alpha
          put Beta
          put Dodo
          put Delta
        } |
          assertions:should-not-emit [
            90
            Alpha
            Dodo
            $true
          ]
      } catch {
      } |
        should-emit [
          "\e[;1;31mUnexpected values found:\e[m"
          '['
          ' Alpha'
          ' Dodo'
          ']'
          "\e[;1;32mEmitted values:\e[m"
          '['
          ' Alpha'
          ' Beta'
          ' Dodo'
          ' Delta'
          ']'
        ]
    }

    >> 'with numbers and numeric strings' {
      throws {
        {
          put 90
          put 91
          put 92
        } |
          assertions:should-not-emit [
            (num 91)
          ]
      } |
        get-fail-content |
        should-be 'should-not-emit assertion failed'
    }
  }

  >> 'when strict' {
    >> 'when none of the unexpected value is emitted' {
      {
        put Alpha
        put Beta
        put Gamma
      } |
        assertions:should-not-emit &strict [
          90
          Dodo
          $true
        ]
    }

    >> 'when one of the unexpected values is emitted' {
      throws {
        {
          put Alpha
          put Beta
          put Dodo
          put Delta
        } |
          assertions:should-not-emit &strict [
            90
            Dodo
            $true
          ]
      } |
        get-fail-content |
        should-be 'strict should-not-emit assertion failed'
    }

    >> 'with numbers and numeric strings' {
      {
        put 90
        put 91
        put 92
      } |
        assertions:should-not-emit &strict [
          (num 91)
        ]
    }
  }
}

>> 'Assertions: should-contain' {
  >> 'when the container is not supported' {
    throws {
      put (num 90) |
        assertions:should-contain 92
    } |
      get-fail-content |
      should-be 'Cannot assert should-contain - unexpected container kind: number'
  }

  >> 'when the container is a string' {
    >> 'when the sub-string is present' {
      put 'Greetings, magic world!' |
        assertions:should-contain magic
    }

    >> 'when the sub-string is missing' {
      throws {
        put 'Hello, everybody!' |
          assertions:should-contain world
      } |
        get-fail-content |
        should-be $assertions:-should-contain-error-message
    }
  }

  >> 'when the container is a list' {
    >> 'when the item is present' {
      put [alpha beta gamma] |
        assertions:should-contain beta
    }

    >> 'when the item is missing' {
      throws {
        put [alpha beta gamma] |
          assertions:should-contain ro
      } |
        get-fail-content |
        should-be $assertions:-should-contain-error-message
    }

    >> 'when the list contains string representations of numbers' {
      >> 'when the item is a number' {
        >> 'by default' {
          put [90 92 95 98] |
            assertions:should-contain (num 92)
        }

        >> 'when strict equality is enabled' {
          throws {
            put [90 92 95 98] |
              assertions:should-contain &strict (num 92)
          } |
            get-fail-content |
            should-be 'strict '$assertions:-should-contain-error-message
        }
      }
    }
  }

  >> 'when the container is a map' {
    >> 'when the key is present' {
      put [
        &a=90
        &b=92
        &c=95
      ] |
        assertions:should-contain b
    }

    >> 'when the key is missing' {
      throws {
        put [
          &a=90
          &b=92
          &c=95
        ] |
          assertions:should-contain omega
      } |
        get-fail-content |
        should-be $assertions:-should-contain-error-message
    }
  }

  >> 'when the container is a set from Ethereal' {
    >> 'when the item is present' {
      all [alpha beta gamma] |
        set:of |
        assertions:should-contain beta
    }

    >> 'when the item is missing' {
      throws {
        all [alpha beta gamma] |
          set:of |
          assertions:should-contain ro
      } |
        get-fail-content |
        should-be $assertions:-should-contain-error-message
    }

    >> 'when the set contains string representations of numbers' {
      >> 'when the item is a number' {
        >> 'by default' {
          all [90 92 95 98] |
            set:of |
            assertions:should-contain (num 92)
        }

        >> 'when strict equality is enabled' {
          throws {
            all [90 92 95 98] |
              set:of |
              assertions:should-contain &strict (num 92)
          } |
            get-fail-content |
            should-be 'strict '$assertions:-should-contain-error-message
        }
      }
    }
  }
}

>> 'Assertions: fail-test' {
  >> 'when raising a test failure' {
    assertions:throws {
      assertions:fail-test
    } |
      exception:get-fail-content |
      assertions:should-be 'TEST SET TO FAIL'
  }
}