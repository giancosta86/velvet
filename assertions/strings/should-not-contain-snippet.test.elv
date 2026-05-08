use ./should-not-contain-snippet

var should-not-contain-snippet~ = $should-not-contain-snippet:should-not-contain-snippet~

>> 'Assertions' {
  >> 'should-not-contain-snippet' {
    >> 'when the subject is not a string' {
      fails {
        put [90 92 95] |
          should-not-contain-snippet []
      }
    }

    >> 'when the snippet is contained' {
      var failing-block = {
        put "Alpha\nBeta\nGamma\nDelta\nEpsilon" |
          should-not-contain-snippet [
            Beta
            Gamma
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
            'Unexpected snippet:'
            Beta
            Gamma
            '🔎 DIFF:'
            '@@ -1,2 +1,5 @@'
            +Alpha
            ' Beta'
            -Gamma
            '\ No newline at end of file'
            +Gamma
            +Delta
            +Epsilon
            '\ No newline at end of file'
            🔎🔎🔎
          ]
      }
    }

    >> 'when the snippet is not contained' {
      put "Alpha\nBeta\nGamma\nDelta\nEpsilon" |
        should-not-contain-snippet [
          Beta
          MISSING-STRING
        ]
    }
  }
}