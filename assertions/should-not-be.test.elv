use ./shared
use ./should-not-be

var should-not-be~ = $should-not-be:should-not-be~

var expect-failure~ = (shared:create-expect-failure $should-not-be~ $should-not-be:-error-message-base)

>> ' should-not-be (strict)' {
  >> 'with equal strings' {
    expect-failure &strict Alpha Alpha
  }

  >> 'with different strings' {
    put Alpha |
      should-not-be &strict Beta
  }

  >> 'with equal numbers' {
    expect-failure &strict (num 90) (num 90)
  }

  >> 'with string and number denoting the same value' {
    put 90 |
      should-not-be &strict (num 90)
  }
}

>> ' should-not-be (non-strict)' {
  >> 'with equal strings' {
    expect-failure Alpha Alpha
  }

  >> 'with different strings' {
    put Alpha |
      should-not-be Beta
  }

  >> 'with string and number having same value' {
    expect-failure 90 (num 90)
  }

  >> 'with different booleans' {
    put $false |
      should-not-be $true

    put $true |
      should-not-be $false
  }

  >> 'with equal multi-level lists' {
    var test-list = [Alpha [Beta [Gamma Delta] Epsilon] Zeta Eta Theta]

    expect-failure $test-list $test-list
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

    expect-failure $test-map $test-map
  }
}