use ../block-handlers/assertion-fails
use ./should-not-be

var should-not-be~ = $should-not-be:should-not-be~

var assertion-fails~ = $assertion-fails:assertion-fails~

>> 'Assertions' {
  >> 'should-not-be' {
    >> 'non-strict' {
      >> 'with equal strings' {
        assertion-fails (src) {
          put Alpha |
            should-not-be Alpha
        }
      }

      >> 'with different strings' {
        put Alpha |
          should-not-be Beta
      }

      >> 'with string and number having same value' {
        assertion-fails (src) {
          put 90 |
            should-not-be (num 90)
        }
      }

      >> 'with different booleans' {
        put $false |
          should-not-be $true

        put $true |
          should-not-be $false
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

        assertion-fails (src) {
          put $test-list |
            should-not-be $test-list
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

        assertion-fails (src) {
          put $test-map |
            should-not-be $test-map
        }
      }
    }

    >> 'strict' {
      >> 'with equal strings' {
        assertion-fails (src) {
          put Alpha |
            should-not-be &strict Alpha
        }
      }

      >> 'with different strings' {
        put Alpha |
          should-not-be &strict Beta
      }

      >> 'with equal numbers' {
        assertion-fails (src) {
          put (num 90) |
            should-not-be &strict (num 90)
        }
      }

      >> 'with string and number denoting the same value' {
        put 90 |
          should-not-be &strict (num 90)
      }
    }

    >> 'when failing' {
      >> 'the output should describe the context' {
        var output-tester = (
          throws &swallow {
            put Alpha |
              should-not-be Alpha
          } |
            create-output-tester &unstyled
        )

        $output-tester[should-contain-snippet] [
          'Unexpected value:'
          Alpha
        ]
      }
    }
  }
}
