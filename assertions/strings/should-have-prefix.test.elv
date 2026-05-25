use ./should-have-prefix

var should-have-prefix~ = $should-have-prefix:should-have-prefix~

>> 'Assertions' {
  >> 'strings' {
    >> 'should-have-prefix' {
      >> 'when the subject is not a string' {
        fails {
          put [90 92 95 98] |
            should-have-prefix 'dodo'
        } |
          should-be 'The subject must be a string'
      }

      >> 'when the argument is not a string' {
        fails {
          put 'Dodo' |
            should-have-prefix [90 92 95 98]
        } |
          should-be 'The assertion argument must be a string'
      }

      >> 'when the prefix is contained' {
        put 'Greetings' |
          should-have-prefix 'Greet'
      }

      >> 'when the prefix is not contained' {
        var failing-block = {
          put Hello |
            should-have-prefix '<SOME OTHER STRING>'
        }

        >> 'should fail' {
          assertion-fails (src) $failing-block
        }

        >> 'should describe the context' {
          capture &throws $failing-block |
            should-contain-snippet [
              'Actual string:'
              Hello
              'Expected prefix:'
              '<SOME OTHER STRING>'
            ]
        }
      }
    }
  }
}