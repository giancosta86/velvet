use ./should-not-have-suffix

var should-not-have-suffix~ = $should-not-have-suffix:should-not-have-suffix~

>> 'Assertions' {
  >> 'strings' {
    >> 'should-not-have-suffix' {
      >> 'when the subject is not a string' {
        fails {
          put [90 92 95 98] |
            should-not-have-suffix 'dodo'
        } |
          should-be 'The subject must be a string'
      }

      >> 'when the argument is not a string' {
        fails {
          put 'Dodo' |
            should-not-have-suffix [90 92 95 98]
        } |
          should-be 'The assertion argument must be a string'
      }

      >> 'when the suffix is contained' {
        var failing-block = {
          put 'Greetings' |
            should-not-have-suffix 'ings'
        }

        >> 'should fail' {
          assertion-fails (src) $failing-block
        }

        >> 'should describe the context' {
          capture &throws $failing-block |
            should-contain-snippet [
              'Actual string:'
              Greetings
              'Unexpected suffix:'
              'ings'
            ]
        }
      }

      >> 'when the suffix is not contained' {
        put Hello |
          should-not-have-suffix '<SOME OTHER STRING>'
      }
    }
  }
}