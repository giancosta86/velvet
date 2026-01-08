use ./fails
use ./shared
use ./should-contain

var fails~ = $fails:fails~
var should-contain~ = $should-contain:should-contain~

var expect-failure~ = (shared:create-expect-failure $should-contain~ $should-contain:-error-message-base)

>> 'Assertions: should-contain' {
  >> 'when the container is a number' {
    >> 'in non-strict mode' {
      >> 'it should convert the container to string' {
        put (num 9020192) |
          should-contain '201'
      }
    }

    >> 'in strict mode' {
      >> 'it should fail' {
        fails {
          put (num 90) |
            should-contain &strict ANYTHING
        } |
          should-be 'Unsupported container kind: number'
      }
    }
  }

  >> 'when the container is a string' {
    >> 'when the sub-string is present' {
      put 'Greetings, magic world!' |
        should-contain magic
    }

    >> 'when the sub-string is missing' {
      expect-failure 'Hello, everybody!' world
    }
  }

  >> 'when the container is a list' {
    >> 'when the item is present' {
      put [alpha beta gamma] |
        should-contain beta
    }

    >> 'when the item is missing' {
      expect-failure [alpha beta gamma] ro
    }

    >> 'when the list contains string representations of numbers' {
      >> 'when the item is a number' {
        >> 'by default' {
          put [90 92 95 98] |
            should-contain (num 92)
        }

        >> 'when strict equality is enabled' {
          expect-failure &strict [90 92 95 98] (num 92)
        }
      }
    }
  }

  >> 'when the container is a map' {
    >> 'when the key is present' {
      put [
        &a=90
        &b=92
        &c=95
      ] |
        should-contain b
    }

    >> 'when the key is missing' {
      expect-failure [
        &a=90
        &b=92
        &c=95
      ] omega
    }
  }

  >> 'when the container is a set from Ethereal' {
    >> 'when the item is present' {
      all [alpha beta gamma] |
        set:of |
        should-contain beta
    }

    >> 'when the item is missing' {
      expect-failure (set:of [alpha beta gamma]) ro
    }

    >> 'when the set contains string representations of numbers' {
      >> 'when the item is a number' {
        >> 'by default' {
          all [90 92 95 98] |
            set:of |
            should-contain (num 92)
        }

        >> 'when strict equality is enabled' {
          expect-failure &strict (set:of [90 92 95 98]) (num 92)
        }
      }
    }
  }
}
