use ../../block-handlers/assertion-fails
use ./should-not-contain

var assertion-fails~ = $assertion-fails:assertion-fails~
var should-not-contain~ = $should-not-contain:should-not-contain~

>> 'Assertions: should-not-contain' {
  >> 'when the argument is not a collection' {
    >> 'in non-strict mode' {
      >> 'it should convert the number to string' {
        put (num 90) |
          should-not-contain '27'
      }
    }

    >> 'in strict mode' {
      >> 'it should fail' {
        fails {
          put (num 90) |
            should-not-contain &strict ANYTHING
        } |
          should-be 'Data type not supported as a collection: number'
      }
    }
  }

  >> 'when the collection is a string' {
    >> 'when the sub-string is present' {
      assertion-fails (src) {
        put 'Greetings, magic world!' |
          should-not-contain magic
      }
    }

    >> 'when the sub-string is missing' {
      put 'Hello, everybody!' |
        should-not-contain world
    }
  }

  >> 'when the collection is a list' {
    >> 'when the item is present' {
      assertion-fails (src) {
        put [alpha beta gamma] |
          should-not-contain beta
      }
    }

    >> 'when the item is missing' {
      put [alpha beta gamma] |
        should-not-contain ro
    }

    >> 'when the list contains string representations of numbers' {
      >> 'when the item is a number' {
        >> 'by default' {
          assertion-fails (src) {
            put [90 92 95 98] |
              should-not-contain (num 92)
          }
        }

        >> 'when strict equality is enabled' {
          put [90 92 95 98] |
            should-not-contain &strict (num 92)
        }
      }
    }
  }

  >> 'when the collection is a map' {
    >> 'when the key is present' {
      assertion-fails (src) {
        put [
          &a=90
          &b=92
          &c=95
        ] |
          should-not-contain b
      }
    }

    >> 'when the key is missing' {
      put [
        &a=90
        &b=92
        &c=95
      ] |
        should-not-contain omega
    }
  }

  >> 'when the collection is a set from Ethereal' {
    >> 'when the item is present' {
      assertion-fails (src) {
        set:of alpha beta gamma |
          should-not-contain beta
      }
    }

    >> 'when the item is missing' {
      set:of alpha beta gamma |
        should-not-contain ro
    }

    >> 'when the set contains string representations of numbers' {
      >> 'when the item is a number' {
        >> 'by default' {
          assertion-fails (src) {
            set:of 90 92 95 98 |
              should-not-contain (num 92)
          }
        }

        >> 'when strict equality is enabled' {
          set:of 90 92 95 98 |
            should-not-contain &strict (num 92)
        }
      }
    }
  }

  >> 'when failing' {
    >> 'the output should describe the context' {
      >> 'for string' {
        capture &throws {
          put Alpha |
            should-not-contain ph
        } |
          should-contain-snippet [
            'Actual string:'
            Alpha
            'Unexpected substring:'
            ph
          ]
      }

      >> 'for list' {
        capture &throws {
          put [Alpha] |
            should-not-contain Alpha
        } |
          should-contain-snippet [
            'Actual list:'
            '['
            ' Alpha'
            ']'
            'Unexpected item:'
            Alpha
          ]
      }

      >> 'for map' {
        capture &throws {
          put [&Alpha=90] |
            should-not-contain Alpha
        } |
          should-contain-snippet [
            'Actual map:'
            '['
            " &Alpha=\t90"
            ']'
            'Unexpected key:'
            Alpha
          ]
      }

      >> 'for set' {
        capture &throws {
          set:of Alpha |
            should-not-contain Alpha
        } |
          should-contain-snippet [
            'Actual ethereal-set:'
            '['
            ' Alpha'
            ']'
            'Unexpected item:'
            Alpha
          ]
      }
    }
  }
}
