use ./should-contain-none

var should-contain-none~ = $should-contain-none:should-contain-none~

>> 'Assertions' {
  >> 'should-contain-none' {
    >> 'when the argument is not a collection' {
      >> 'when non-strict' {
        put [90 92 95 98] |
          should-contain-none (num 90)
      }

      >> 'when strict' {
        fails {
          put [90 92 95 98] |
            should-contain-none &strict (num 90)
        } |
          should-be 'Data type not supported as a collection: number'
      }
    }

    >> 'when the collection is a string' {
      >> 'when the sub-strings are present' {
        assertion-fails (src) {
          put 'Greetings, magic world!' |
            should-contain-none [
              magic
              world
            ]
        }
      }

      >> 'when the sub-strings are missing' {
        put 'Hello, everybody!' |
          should-contain-none [
            chipmunk
            dodo
          ]
      }
    }

    >> 'when the collection is a list' {
      >> 'when all the items are present' {
        assertion-fails (src) {
          put [alpha beta gamma] |
            should-contain-none [
              beta
              gamma
            ]
        }
      }

      >> 'when the items are missing' {
        put [alpha beta gamma] |
          should-contain-none [
            ro
            omega
          ]
      }

      >> 'when the list contains string representations of numbers' {
        >> 'when the excluded items are numbers' {
          >> 'when non-strict' {
            assertion-fails (src) {
              put [90 92 95 98] |
                should-contain-none [
                  (num 92)
                  (num 95)
                  (num 98)
                ]
            }
          }

          >> 'when strict' {
            put [90 92 95 98] |
              should-contain-none &strict [
                (num 92)
              ]
          }
        }
      }
    }

    >> 'when the collection is a map' {
      >> 'when all the keys are present' {
        assertion-fails (src) {
          put [
            &a=90
            &b=92
            &c=95
          ] |
            should-contain-none [
              b
              c
            ]
        }
      }

      >> 'when all the keys are missing' {
        put [
          &a=90
          &b=92
          &c=95
        ] |
          should-contain-none [
            omega
            chipmunk
          ]
      }
    }

    >> 'when the collection is a set from Ethereal' {
      >> 'when all the items are present' {
        assertion-fails (src) {
          all [alpha beta gamma] |
            set:of |
            should-contain-none [
              alpha
              beta
              gamma
            ]
        }
      }

      >> 'when all the items are missing' {
        set:from [alpha beta gamma] |
          should-contain-none [
            ro
            omega
          ]
      }

      >> 'when the set contains string representations of numbers' {
        >> 'when the excluded items are numbers' {
          >> 'when non-strict' {
            assertion-fails (src) {
              all [90 92 95 98] |
                set:of |
                should-contain-none [
                  (num 92)
                  (num 95)
                  (num 98)
                ]
            }
          }

          >> 'when strict' {
            set:from [90 92 95 98] |
              should-contain-none &strict [
                (num 92)
                (num 98)
              ]
          }
        }
      }
    }

    >> 'when failing' {
      >> 'the output should describe the context' {
        >> 'for string' {
          capture &throws {
            put Alpha |
              should-contain-none [
                lph
                Dodo
                od
                Alp
              ]
          } |
            should-contain-snippet [
              'Actual string:'
              Alpha
              'Unexpected substrings:'
              '['
              ' lph'
              ' Alp'
              ']'
            ]
        }

        >> 'for list' {
          capture &throws {
            put [90 92 95 98] |
              should-contain-none [
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
              'Unexpected items:'
              '['
              ' 95'
              ' 90'
              ']'
            ]
        }

        >> 'for map' {
          capture &throws {
            put [&a=90 &b=92 &c=95] |
              should-contain-none [
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
              'Unexpected keys:'
              '['
              ' a'
              ' b'
              ' c'
              ']'
            ]
        }

        >> 'for set' {
          capture &throws {
            set:of Alpha |
              should-contain-none [
                Dodo
                Alpha
                Yogi
              ]
          } |
            should-contain-snippet [
              'Actual ethereal-set:'
              '['
              ' Alpha'
              ']'
              'Unexpected items:'
              '['
              ' Alpha'
              ']'
            ]
        }
      }
    }
  }
}