use ../block-handlers/assertion-fails
use ./should-be

var assertion-fails~ = $assertion-fails:assertion-fails~
var should-be~ = $should-be:should-be~

>> 'Assertions' {
  >> 'should-be' {
    >> 'non-strict' {
      >> 'with equal strings' {
        put Alpha |
          should-be Alpha
      }

      >> 'with different strings' {
        assertion-fails (src) {
          put Alpha |
            should-be Beta
        }
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
        assertion-fails (src) {
          put Alpha |
            should-be &strict Beta
        }
      }

      >> 'with equal numbers' {
        put (num 90) |
          should-be &strict (num 90)
      }

      >> 'with number and numeric string' {
        assertion-fails (src) {
          put 90 |
            should-be &strict (num 90)
        }
      }

      >> 'with equal booleans' {
        put $false |
          should-be &strict $false

        put $true |
          should-be &strict $true
      }

      >> 'with equal multi-level lists' {
        var test-list = [
          Alpha
          [
            Beta
            [
              Gamma
              Delta
            ]
            Epsilon
          ]
          Zeta
          Eta
          Theta
        ]

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

    >> 'when failing' {
      >> 'the output should describe the context' {
        capture &throws {
          put Alpha |
            should-be Beta
        } |
          should-contain-snippet [
            Actual:
            Alpha
            Expected:
            Beta
            '🔎 DIFF:'
            '@@ -1 +1 @@'
            -Beta
            '\ No newline at end of file'
            +Alpha
            '\ No newline at end of file'
            🔎🔎🔎
          ]
      }
    }
  }
}
