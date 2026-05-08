use ../block-handlers/assertion-fails
use ./should-emit

var should-emit~ = $should-emit:should-emit~

var assertion-fails~ = $assertion-fails:assertion-fails~

>> 'Assertions' {
  >> 'should-emit' {
    >> 'non-strict' {
      >> 'when the argument is not a list' {
        fails {
          {
            put 90
          } |
            should-emit 90
        } |
          should-be 'The expected argument must be a list'
      }

      >> 'when emitting nothing' {
        { } |
          should-emit []
      }

      >> 'when emitting a string' {
        {
          put 'Hello, world!'
        } |
          should-emit [
            'Hello, world!'
          ]
      }

      >> 'when emitting a number' {
        >> 'when in string format' {
          {
            put 90
          } |
            should-emit [
              90
            ]
        }

        >> 'when in different formats' {
          {
            put 90
          } |
            should-emit [
              (num 90)
            ]
        }
      }

      >> 'when emitting both a string and a number' {
        {
          put Hello
          put 90
        } |
          should-emit [
            Hello
            (num 90)
          ]
      }

      >> 'when emitting via echo' {
        {
          echo Hello
          echo World
        } |
          should-emit [
            Hello
            World
          ]
      }
    }

    >> 'strict' {
      >> 'when the data type is the same' {
        {
          put 90
        } |
          should-emit &strict [
            90
          ]
      }

      >> 'when the data type is different' {
        assertion-fails (src) {
          put 90 |
            should-emit &strict [
              (num 90)
            ]
        }
      }
    }

    >> 'when the order is wrong' {
      assertion-fails (src) {
        {
          put 95
          put 90
          put 98
          put 100
          put 92
        } |
          should-emit [
            90
            92
            95
            98
            100
          ]
      }
    }

    >> 'when ordering via a key' {
      {
        put 95
        put 90
        put 98
        put 100
        put 92
      } |
        should-emit &order-key=$num~ [
          90
          92
          95
          98
          100
        ]
    }

    >> 'when any order is admitted' {
      >> 'when the actual items and the expected items are the same, but in different order' {
        all [
          92
          90
          (num 98)
          95
        ] |
          should-emit &any-order [
            90
            92
            95
            98
          ]
      }

      >> 'when passing an order-key, too' {
        fails {
          all [
            90
            92
          ] |
            should-emit &order-key=$num~ &any-order [
              92
              90
            ]
        } |
          should-be 'The &any-order flag and the &order-key option are mutually exclusive!'
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
            should-emit [
              Ro
              Sigma
            ]
        } |
          should-contain-snippet [
            'Emitted values:'
            '['
            ' Alpha'
            ' Beta'
            ' Gamma'
            ']'
            'Expected values:'
            '['
            ' Ro'
            ' Sigma'
            ']'
            '🔎 DIFF:'
            '@@ -1,4 +1,5 @@'
            ' ['
            '- Ro'
            '- Sigma'
            '+ Alpha'
            '+ Beta'
            '+ Gamma'
            ' ]'
            '\ No newline at end of file'
            🔎🔎🔎
          ]
      }
    }
  }
}
