use ./should-match-regex

var should-match-regex~ = $should-match-regex:should-match-regex~

>> 'Assertions' {
  >> 'strings' {
    >> 'should-match-regex' {
      >> 'when the subject is not a string' {
        fails {
          put [90 92 95 98] |
            should-match-regex 'dodo'
        } |
          should-be 'The subject must be a string'
      }

      >> 'when the argument is not a string' {
        fails {
          put 'Dodo' |
            should-match-regex [90 92 95 98]
        } |
          should-be 'The assertion argument must be a string'
      }

      >> 'when the pattern is matched' {
        put 'ABC' |
          should-match-regex 'A.C'
      }

      >> 'when the pattern is not matched' {
        var failing-block = {
          put Hello |
            should-match-regex 'A.C'
        }

        >> 'should fail' {
          assertion-fails (src) $failing-block
        }

        >> 'should describe the context' {
          capture &throws $failing-block |
            should-contain-snippet [
              'Actual string:'
              Hello
              'Expected regex pattern:'
              A.C
            ]
        }
      }
    }
  }
}