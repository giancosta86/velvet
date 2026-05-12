use ./should-have-suffix

var should-have-suffix~ = $should-have-suffix:should-have-suffix~

>> 'Assertions' {
  >> 'strings' {
    >> 'should-have-suffix' {
      >> 'when the subject is not a string' {
        fails {
          put [90 92 95 98] |
            should-have-suffix 'dodo'
        } |
          should-be 'The subject must be a string'
      }

      >> 'when the argument is not a string' {
        fails {
          put 'Dodo' |
            should-have-suffix [90 92 95 98]
        } |
          should-be 'The assertion argument must be a string'
      }

      >> 'when the suffix is contained' {
        put 'Greetings' |
          should-have-suffix 'ings'
      }

      >> 'when the suffix is not contained' {
        var failing-block = {
          put Hello |
            should-have-suffix '<SOME OTHER STRING>'
        }

        >> 'should fail' {
          assertion-fails (src) $failing-block
        }

        >> 'should describe the context' {
          capture &throws $failing-block |
            should-contain-snippet [
              'Actual string:'
              Hello
              'Expected suffix:'
              '<SOME OTHER STRING>'
            ]
        }
      }
    }
  }
}