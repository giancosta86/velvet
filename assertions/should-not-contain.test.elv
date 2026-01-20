use ./fails
use ./shared
use ./should-not-contain

var fails~ = $fails:fails~
var should-not-contain~ = $should-not-contain:should-not-contain~

var expect-failure~ = (shared:create-expect-failure $should-not-contain~ $should-not-contain:-error-message-base)

>> 'Assertions: should-not-contain' {
  >> 'when the container is a number' {
    >> 'in non-strict mode' {
      >> 'it should convert the container to string' {
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
      expect-failure 'Greetings, magic world!' magic
    }

    >> 'when the sub-string is missing' {
      put 'Hello, everybody!' |
        should-not-contain world
    }
  }

  >> 'when the container is a list' {
    >> 'when the item is present' {
      expect-failure [alpha beta gamma] beta
    }

    >> 'when the item is missing' {
      put [alpha beta gamma] |
        should-not-contain ro
    }

    >> 'when the list contains string representations of numbers' {
      >> 'when the item is a number' {
        >> 'by default' {
          expect-failure [90 92 95 98] (num 92)
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
      expect-failure [
        &a=90
        &b=92
        &c=95
      ] b
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
      expect-failure (set:of alpha beta gamma) beta
    }

    >> 'when the item is missing' {
      set:of alpha beta gamma |
        should-not-contain ro
    }

    >> 'when the set contains string representations of numbers' {
      >> 'when the item is a number' {
        >> 'by default' {
          expect-failure (set:of 90 92 95 98) (num 92)
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
