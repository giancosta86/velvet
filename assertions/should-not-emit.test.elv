use ../block-handlers/assertion-fails
use ./should-not-emit

var assertion-fails~ = $assertion-fails:assertion-fails~
var should-not-emit~ = $should-not-emit:should-not-emit~

>> 'Assertions' {
  >> 'should-not-emit' {
    >> 'when the argument is not a list' {
      fails {
        {
          put 90
        } |
          should-not-emit 90
      } |
        should-be 'The unexpected argument must be a list'
    }

    >> 'non-strict' {
      >> 'when none of the unexpected value is emitted' {
        {
          put Alpha
          put Beta
          put Gamma
        } |
          should-not-emit [
            90
            Dodo
            $true
          ]
      }

      >> 'when one of the unexpected values is emitted' {
        assertion-fails (src) {
          {
            put Alpha
            put Beta
            put Dodo
            put Delta
          } |
            should-not-emit [
              90
              Dodo
              $true
            ]
        }
      }

      >> 'when multiple unexpected values are emitted' {
        assertion-fails (src) {
          {
            put Alpha
            put Beta
            put Dodo
            put Delta
          } |
            should-not-emit [
              90
              Alpha
              92
              Dodo
              $true
            ]
        }
      }

      >> 'with numbers and numeric strings' {
        assertion-fails (src) {
          {
            put 90
            put 91
            put 92
          } |
            should-not-emit [
              (num 91)
            ]
        }
      }
    }

    >> 'strict' {
      >> 'when none of the unexpected value is emitted' {
        {
          put Alpha
          put Beta
          put Gamma
        } |
          should-not-emit &strict [
            90
            Dodo
            $true
          ]
      }

      >> 'when one of the unexpected values is emitted' {
        assertion-fails (src) {
          {
            put Alpha
            put Beta
            put Dodo
            put Delta
          } |
            should-not-emit &strict [
              90
              Dodo
              $true
            ]
        }
      }

      >> 'with numbers and numeric strings' {
        {
          put 90
          put 91
          put 92
        } |
          should-not-emit &strict [
            (num 91)
          ]
      }
    }

    >> 'when failing' {
      >> 'the output should describe the context' {
        capture &throws {
          {
            put Alpha
            put Beta
            put Gamma
          } |
            should-not-emit [
              Alpha
              Omega
              Beta
            ]
        } |
          should-contain-snippet [
            'Unexpected values:'
            '['
            ' Alpha'
            ' Beta'
            ']'
          ]
      }
    }
  }
}
