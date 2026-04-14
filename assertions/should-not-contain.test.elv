use ./assertion-fails
use ./fails
use ./should-not-contain

var assertion-fails~ = $assertion-fails:assertion-fails~
var fails~ = $fails:fails~
var should-not-contain~ = $should-not-contain:should-not-contain~

>> 'Assertions: should-not-contain' {
  >> 'when the container is a number' {
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
          should-be 'Unsupported container kind: number'
      }
    }
  }

  >> 'when the container is a string' {
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

  >> 'when the container is a list' {
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

  >> 'when the container is a map' {
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

  >> 'when the container is a set from Ethereal' {
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
        var output-tester = (
          throws &swallow {
            put Alpha |
              should-not-contain ph
          } |
            create-output-tester &unstyled
        )

        $output-tester[should-contain-snippet] [
          'Unexpected substring:'
          ph
          'Actual string:'
          Alpha
        ]
      }

      >> 'for list' {
        var output-tester = (
          throws &swallow {
            put [Alpha] |
              should-not-contain Alpha
          } |
            create-output-tester &unstyled
        )

        $output-tester[should-contain-snippet] [
          'Unexpected item:'
          Alpha
          'Actual list:'
          '['
          ' Alpha'
          ']'
        ]
      }

      >> 'for map' {
        var output-tester = (
          throws &swallow {
            put [&Alpha=90] |
              should-not-contain Alpha
          } |
            create-output-tester &unstyled
        )

        $output-tester[should-contain-snippet] [
          'Unexpected key:'
          Alpha
          'Actual map:'
          '['
          " &Alpha=\t90"
          ']'
        ]
      }

      >> 'for set' {
        var output-tester = (
          throws &swallow {
            set:of Alpha |
              should-not-contain Alpha
          } |
            create-output-tester &unstyled
        )

        $output-tester[should-contain-snippet] [
          'Unexpected item:'
          Alpha
          'Actual ethereal-set:'
          '['
          ' Alpha'
          ']'
        ]
      }
    }
  }
}
