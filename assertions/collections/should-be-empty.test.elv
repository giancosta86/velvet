use github.com/giancosta86/ethereal/v1/set
use ../../block-handlers/assertion-fails
use ./should-be-empty

var assertion-fails~ = $assertion-fails:assertion-fails~
var should-be-empty~ = $should-be-empty:should-be-empty~

>> 'Assertions' {
  >> 'should-be-empty' {
    >> 'when there is a number instead of a collection' {
      fails {
        put (num 90) |
          should-be-empty
      } |
        should-be 'Data type not supported as a collection: number'
    }

    >> 'when the collection is a string' {
      >> 'when empty' {
        put '' |
          should-be-empty
      }

      >> 'when non-empty' {
        assertion-fails (src) {
          put Hello |
            should-be-empty
        }
      }
    }

    >> 'when the collection is a list' {
      >> 'when empty' {
        put [] |
          should-be-empty
      }

      >> 'when non-empty' {
        assertion-fails (src) {
          put [90 92 95 98] |
            should-be-empty
        }
      }
    }

    >> 'when the collection is a map' {
      >> 'when empty' {
        put [&] |
          should-be-empty
      }

      >> 'when non-empty' {
        assertion-fails (src) {
          put [&a=90] |
            should-be-empty
        }
      }
    }

    >> 'when the collection is a set from Ethereal' {
      >> 'when empty' {
        put $set:empty |
          should-be-empty
      }

      >> 'when non-empty' {
        assertion-fails (src) {
          set:of 90 92 95 98 |
            should-be-empty
        }
      }
    }

    >> 'when failing' {
      >> 'the output should describe the context' {
        >> 'for list' {
          var output-tester = (
            throws &swallow {
              put [90 92 95] |
                should-be-empty
            } |
              create-output-tester &unstyled
          )

          $output-tester[should-contain-snippet] [
            'Unexpected non-empty list:'
            '['
            ' 90'
            ' 92'
            ' 95'
            ']'
          ]
        }
      }
    }
  }
}
