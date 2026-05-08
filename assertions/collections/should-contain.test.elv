use ./should-contain

var should-contain~ = $should-contain:should-contain~

>> 'Assertions' {
  >> 'should-contain' {
    >> 'when the argument is not a collection' {
      >> 'when non-strict' {
        >> 'it should convert the number to string' {
          put (num 9020192) |
            should-contain '201'
        }
      }

      >> 'when strict' {
        >> 'it should fail' {
          fails {
            put (num 90) |
              should-contain &strict ANYTHING
          } |
            should-be 'Data type not supported as a collection: number'
        }
      }
    }

    >> 'when the collection is a string' {
      >> 'when the sub-string is present' {
        put 'Greetings, magic world!' |
          should-contain magic
      }

      >> 'when the sub-string is missing' {
        assertion-fails (src) {
          put 'Hello, everybody!' |
            should-contain world
        }
      }
    }

    >> 'when the collection is a list' {
      >> 'when the item is present' {
        put [alpha beta gamma] |
          should-contain beta
      }

      >> 'when the item is missing' {
        assertion-fails (src) {
          put [alpha beta gamma] |
            should-contain ro
        }
      }

      >> 'when the list contains string representations of numbers' {
        >> 'when the item is a number' {
          >> 'when non-strict' {
            put [90 92 95 98] |
              should-contain (num 92)
          }

          >> 'when strict' {
            assertion-fails (src) {
              put [90 92 95 98] |
                should-contain &strict (num 92)
            }
          }
        }
      }
    }

    >> 'when the collection is a map' {
      >> 'when the key is present' {
        put [
          &a=90
          &b=92
          &c=95
        ] |
          should-contain b
      }

      >> 'when the key is missing' {
        assertion-fails (src) {
          put [
            &a=90
            &b=92
            &c=95
          ] |
            should-contain omega
        }
      }
    }

    >> 'when the collection is a set from Ethereal' {
      >> 'when the item is present' {
        all [alpha beta gamma] |
          set:of |
          should-contain beta
      }

      >> 'when the item is missing' {
        assertion-fails (src) {
          set:from [alpha beta gamma] |
            should-contain ro
        }
      }

      >> 'when the set contains string representations of numbers' {
        >> 'when the item is a number' {
          >> 'when non-strict' {
            all [90 92 95 98] |
              set:of |
              should-contain (num 92)
          }

          >> 'when strict' {
            assertion-fails (src) {
              set:from [90 92 95 98] |
                should-contain &strict (num 92)
            }
          }
        }
      }
    }

    >> 'when failing' {
      >> 'the output should describe the context' {
        >> 'for string' {
          capture &throws {
            put Alpha |
              should-contain Dodo
          } |
            should-contain-snippet [
              'Actual string:'
              Alpha
              'Expected substring:'
              Dodo
            ]
        }

        >> 'for list' {
          capture &throws {
            put [Alpha] |
              should-contain Dodo
          } |
            should-contain-snippet [
              'Actual list:'
              '['
              ' Alpha'
              ']'
              'Expected item:'
              Dodo
            ]
        }

        >> 'for map' {
          capture &throws {
            put [&Alpha=90] |
              should-contain Dodo
          } |
            should-contain-snippet [
              'Actual map:'
              '['
              " &Alpha=\t90"
              ']'
              'Expected key:'
              Dodo
            ]
        }

        >> 'for set' {
          capture &throws {
            set:of Alpha |
              should-contain Dodo
          } |
            should-contain-snippet [
              'Actual ethereal-set:'
              '['
              ' Alpha'
              ']'
              'Expected item:'
              Dodo
            ]
        }
      }
    }
  }
}
