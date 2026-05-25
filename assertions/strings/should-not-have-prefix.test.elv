use ./should-not-have-prefix

var should-not-have-prefix~ = $should-not-have-prefix:should-not-have-prefix~

>> 'Assertions' {
  >> 'strings' {
    >> 'should-not-have-prefix' {
      >> 'when the subject is not a string' {
        fails {
          put [90 92 95 98] |
            should-not-have-prefix 'dodo'
        } |
          should-be 'The subject must be a string'
      }

      >> 'when the argument is not a string' {
        fails {
          put 'Dodo' |
            should-not-have-prefix [90 92 95 98]
        } |
          should-be 'The assertion argument must be a string'
      }

      >> 'when the prefix is contained' {
        var failing-block = {
          put 'Greetings' |
            should-not-have-prefix 'Greet'
        }

        >> 'should fail' {
          assertion-fails (src) $failing-block
        }

        >> 'should describe the context' {
          capture &throws $failing-block |
            should-contain-snippet [
              'Actual string:'
              Greetings
              'Unexpected prefix:'
              'Greet'
            ]
        }
      }

      >> 'when the prefix is not contained' {
        put Hello |
          should-not-have-prefix '<SOME OTHER STRING>'
      }
    }
  }
}