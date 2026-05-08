use ./assertion
use ./block-handlers/assertion-fails

>> 'Assertions' {
  var assertion = 'should-be-ninety'

  var fake-src-result = [
    &name='/some/test/'$assertion'.elv'
  ]

  >> 'formatting a failure' {
    >> 'passing the name' {
      assertion:format-failure $assertion |
        should-be 'Assertion failed: '$assertion
    }

    >> 'from src' {
      put $fake-src-result |
        assertion:format-failure |
        should-be 'Assertion failed: '$assertion
    }
  }

  >> 'failing' {
    >> 'passing the name' {
      fails {
        assertion:fail $assertion
      } |
        should-be (
          assertion:format-failure $assertion
        )
    }

    >> 'from src' {
      fails {
        put $fake-src-result |
          assertion:fail
      } |
        should-be (
          assertion:format-failure $assertion
        )
    }
  }

  >> 'getting input' {
    >> 'when non-strict' {
      set:from [Alpha (num 92)] |
        assertion:get-input |
        should-be (set:from [
          Alpha
          92
        ]
      )
    }

    >> 'when strict' {
      put [Alpha (num 92)] |
        assertion:get-input &strict  |
        should-be [
          Alpha
          (num 92)
        ]
    }
  }

  >> 'enforcing predicate' {
    var non-compliant-description = 'Values that are <= 90'

    fn should-be-greater-than-ninety {
      assertion:enforce-predicate 'should-be-greater-than-ninety' { |value| > $value 90 } $non-compliant-description
    }

    >> 'when all values are compliant' {
      capture {
        all [
          92
          95
          98
          101
        ] |
          should-be-greater-than-ninety
      } |
        should-contain-none [
          92
          95
          98
          101
          $non-compliant-description
        ]
    }

    >> 'when there are non-compliant values' {
      var failing-block = {
        all [
          7
          39
          90
          92
          95
        ] |
          should-be-greater-than-ninety
      }

      >> 'should fail' {
        assertion-fails 'should-be-greater-than-ninety' $failing-block
      }

      >> 'should output the non-compliant values' {
        var output = (
          capture &throws $failing-block
        )

        put $output |
          should-contain-all [
            $non-compliant-description
            7
            39
            90
          ]

        put $output |
          should-contain-none [
            92
            95
          ]
      }
    }
  }
}