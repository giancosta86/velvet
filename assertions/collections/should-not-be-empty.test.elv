use github.com/giancosta86/ethereal/v1/set
use ../../block-handlers/assertion-fails
use ./should-not-be-empty

var assertion-fails~ = $assertion-fails:assertion-fails~
var should-not-be-empty~ = $should-not-be-empty:should-not-be-empty~

>> 'Assertions' {
  >> 'should-not-be-empty' {
    >> 'when there is a number instead of a collection' {
      fails {
        put (num 90) |
          should-not-be-empty
      } |
        should-be 'Data type not supported as a collection: number'
    }

    >> 'when the collection is a string' {
      >> 'when empty' {
        assertion-fails (src) {
          put '' |
            should-not-be-empty
        }
      }

      >> 'when non-empty' {
        put Hello |
          should-not-be-empty
      }
    }

    >> 'when the collection is a list' {
      >> 'when empty' {
        assertion-fails (src) {
          put [] |
            should-not-be-empty
        }
      }

      >> 'when non-empty' {
        put [90 92 95 98] |
          should-not-be-empty
      }
    }

    >> 'when the collection is a map' {
      >> 'when empty' {
        assertion-fails (src) {
          put [&] |
            should-not-be-empty
        }
      }

      >> 'when non-empty' {
        put [&a=90] |
          should-not-be-empty
      }
    }

    >> 'when the collection is a set from Ethereal' {
      >> 'when empty' {
        assertion-fails (src) {
          put $set:empty |
            should-not-be-empty
        }
      }

      >> 'when non-empty' {
        set:of 90 92 95 98 |
          should-not-be-empty
      }
    }
  }
}
