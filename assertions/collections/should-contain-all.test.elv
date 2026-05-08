use ../../block-handlers/assertion-fails
use ./should-contain-all

var assertion-fails~ = $assertion-fails:assertion-fails~
var should-contain-all~ = $should-contain-all:should-contain-all~

>> 'Assertions' {
  >> 'should-contain-all' {
    >> 'when the argument is not a collection' {
      >> 'when non-strict' {
        assertion-fails (src) {
          put [90 92 95 98] |
            should-contain-all (num 90)
        }
      }

      >> 'when strict' {
        fails {
          put [90 92 95 98] |
            should-contain-all &strict (num 90)
        } |
          should-be 'Data type not supported as a collection: number'
      }
    }

    >> 'when the collection is a string' {
      >> 'when the sub-strings are present' {
        put 'Greetings, magic world!' |
          should-contain-all [
            magic
            world
          ]
      }

      >> 'when one of the sub-strings is missing' {
        assertion-fails (src) {
          put 'Hello, everybody!' |
            should-contain-all [
              Hello
              chipmunk
              everybody
            ]
        }
      }
    }

    >> 'when the collection is a list' {
      >> 'when all the items are present' {
        put [alpha beta gamma] |
          should-contain-all [
            beta
            gamma
          ]
      }

      >> 'when one of the items is missing' {
        assertion-fails (src) {
          put [alpha beta gamma] |
            should-contain-all [
              beta
              ro
              gamma
            ]
        }
      }

      >> 'when the list contains string representations of numbers' {
        >> 'when the required items are numbers' {
          >> 'when non-strict' {
            put [90 92 95 98] |
              should-contain-all [
                (num 92)
                (num 95)
                (num 98)
              ]
          }

          >> 'when strict' {
            assertion-fails (src) {
              put [90 92 95 98] |
                should-contain-all &strict [
                  (num 92)
                ]
            }
          }
        }
      }
    }

    >> 'when the collection is a map' {
      >> 'when all the keys are present' {
        put [
          &a=90
          &b=92
          &c=95
        ] |
          should-contain-all [
            b
            c
          ]
      }

      >> 'when one of the keys is missing' {
        assertion-fails (src) {
          put [
            &a=90
            &b=92
            &c=95
          ] |
            should-contain-all [
              a
              omega
              c
            ]
        }
      }
    }

    >> 'when the collection is a set from Ethereal' {
      >> 'when all the items are present' {
        all [alpha beta gamma] |
          set:of |
          should-contain-all [
            alpha
            beta
            gamma
          ]
      }

      >> 'when one of the items is missing' {
        assertion-fails (src) {
          set:from [alpha beta gamma] |
            should-contain-all [
              alpha
              ro
              beta
            ]
        }
      }

      >> 'when the set contains string representations of numbers' {
        >> 'when the required items are numbers' {
          >> 'when non-strict' {
            all [90 92 95 98] |
              set:of |
              should-contain-all [
                (num 92)
                (num 95)
                (num 98)
              ]
          }

          >> 'when strict' {
            assertion-fails (src) {
              set:from [90 92 95 98] |
                should-contain-all &strict [
                  (num 92)
                  (num 98)
                ]
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
              should-contain-all [
                lph
                Dodo
                od
                Alp
              ]
          } |
            should-contain-snippet [
              'Actual string:'
              Alpha
              'Missing substrings:'
              '['
              ' Dodo'
              ' od'
              ']'
            ]
        }

        >> 'for list' {
          capture &throws {
            put [90 92 95 98] |
              should-contain-all [
                7
                95
                13
                90
                6
              ]
          } |
            should-contain-snippet [
              'Actual list:'
              '['
              ' 90'
              ' 92'
              ' 95'
              ' 98'
              ']'
              'Missing items:'
              '['
              ' 7'
              ' 13'
              ' 6'
              ']'
            ]
        }

        >> 'for map' {
          capture &throws {
            put [&a=90 &b=92 &c=95] |
              should-contain-all [
                a
                x
                b
                c
              ]
          } |
            should-contain-snippet [
              'Actual map:'
              '['
              " &a=\t90"
              " &b=\t92"
              " &c=\t95"
              ']'
              'Missing keys:'
              '['
              ' x'
              ']'
            ]
        }

        >> 'for set' {
          capture &throws {
            set:of Alpha |
              should-contain-all [
                Alpha
                Dodo
                Yogi
              ]
          } |
            should-contain-snippet [
              'Actual ethereal-set:'
              '['
              ' Alpha'
              ']'
              'Missing items:'
              '['
              ' Dodo'
              ' Yogi'
              ']'
            ]
        }
      }
    }
  }
}