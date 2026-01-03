use ./shared
use ./should-be

var should-be~ = $should-be:should-be~

var expect-failure~ = (shared:create-expect-failure $should-be~ $should-be:-error-message-base)

>> 'Assertions: should-be' {
  >> 'non-strict' {
    >> 'with equal strings' {
      put Alpha |
        should-be Alpha
    }

    >> 'with different strings' {
      expect-failure Alpha Beta
    }

    >> 'with number and numeric string' {
      put 90 |
        should-be (num 90)
    }
  }

  >> 'strict' {
    >> 'with equal strings' {
      put Alpha |
        should-be &strict Alpha
    }

    >> 'with different strings' {
      expect-failure &strict Alpha Beta
    }

    >> 'with equal numbers' {
      put (num 90) |
        should-be &strict (num 90)
    }

    >> 'with number and numeric string' {
      expect-failure &strict 90 (num 90)
    }

    >> 'with equal booleans' {
      put $false |
        should-be &strict $false

      put $true |
        should-be &strict $true
    }

    >> 'with equal multi-level lists' {
      var test-list = [Alpha [Beta [Gamma Delta] Epsilon] Zeta Eta Theta]

      put $test-list |
        should-be &strict $test-list
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
        should-be &strict $test-map
    }
  }
}
