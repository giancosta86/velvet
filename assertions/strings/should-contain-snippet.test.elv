use ../../block-handlers/assertion-fails
use ./should-contain-snippet

var assertion-fails~ = $assertion-fails:assertion-fails~
var should-contain-snippet~ = $should-contain-snippet:should-contain-snippet~

>> 'Assertions' {
  >> 'should-contain-snippet' {
    >> 'when the subject is not a string' {
      fails {
        put [90 92 95] |
          should-contain-snippet []
      }
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
        var output-tester = (
          throws &swallow $failing-block |
            create-output-tester &unstyled
        )

        $output-tester[should-contain-snippet] [
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