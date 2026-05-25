use ./should-not-match-regex

var should-not-match-regex~ = $should-not-match-regex:should-not-match-regex~

>> 'Assertions' {
  >> 'strings' {
    >> 'should-not-match-regex' {
      >> 'when the subject is not a string' {
        fails {
          put [90 92 95 98] |
            should-not-match-regex 'dodo'
        } |
          should-be 'The subject must be a string'
      }

      >> 'when the argument is not a string' {
        fails {
          put 'Dodo' |
            should-not-match-regex [90 92 95 98]
        } |
          should-be 'The assertion argument must be a string'
      }

      >> 'when the pattern is matched' {
        var failing-block = {
          put 'ABC' |
            should-not-match-regex 'A.C'
        }

        >> 'should fail' {
          assertion-fails (src) $failing-block
        }

        >> 'should describe the context' {
          capture &throws $failing-block |
            should-contain-snippet [
              'Actual string:'
              ABC
              'Unexpected regex pattern:'
              A.C
            ]
        }
      }

      >> 'when the pattern is not matched' {
        put Hello |
          should-not-match-regex 'A.C'
      }
    }
  }
}