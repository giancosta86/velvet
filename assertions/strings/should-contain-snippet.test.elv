use ./should-contain-snippet

var should-contain-snippet~ = $should-contain-snippet:should-contain-snippet~

>> 'Assertions' {
  >> 'strings' {
    >> 'should-contain-snippet' {
      >> 'when the subject is not a string' {
        fails {
          put [90 92 95] |
            should-contain-snippet []
        } |
          should-be 'The subject must be a string'
      }

      >> 'when the snippet is contained' {
        put "Alpha\nBeta\nGamma\nDelta\nEpsilon" |
          should-contain-snippet [
            Beta
            Gamma
            Delta
          ]
      }

      >> 'when the snippet is not contained' {
        var failing-block = {
          put "Alpha\nBeta\nGamma\nDelta\nEpsilon" |
            should-contain-snippet [
              Beta
              MISSING-STRING
            ]
        }

        >> 'should fail' {
          assertion-fails (src) $failing-block
        }

        >> 'should describe the context' {
          capture &throws $failing-block |
            should-contain-snippet [
              'Actual string:'
              Alpha
              Beta
              Gamma
              Delta
              Epsilon
              'Expected snippet:'
              Beta
              MISSING-STRING
              '🔎 DIFF:'
              '@@ -1,2 +1,5 @@'
              +Alpha
              ' Beta'
              -MISSING-STRING
              '\ No newline at end of file'
              +Gamma
              +Delta
              +Epsilon
              '\ No newline at end of file'
              🔎🔎🔎
            ]
        }
      }
    }
  }
}