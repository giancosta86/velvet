use ./assertion
use ./block-handlers/assertion-fails

>> 'Assertion' {
  var assertion = 'should-be-ninety'

  fn fake-src {
    put [
      &name='/some/test/'$assertion'.elv'
    ]
  }

  fn fake-test-src {
    put [
      &name='/some/test/'$assertion'.test.elv'
    ]
  }

  >> 'getting the name' {
    >> 'from the name itself' {
      assertion:get-name $assertion |
        should-be $assertion
    }

    >> 'from the script src' {
      fake-src |
        assertion:get-name |
        should-be $assertion
    }

    >> 'from the test script src' {
      fake-test-src |
        assertion:get-name |
        should-be $assertion
    }
  }

  >> 'formatting a failure' {
    >> 'passing the name' {
      assertion:format-failure $assertion |
        should-be 'Assertion failed: '$assertion
    }

    >> 'from src' {
      fake-src |
        assertion:format-failure |
        should-be 'Assertion failed: '$assertion
    }

    >> 'from test' {
      fake-test-src |
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
        fake-src |
          assertion:fail
      } |
        should-be (
          assertion:format-failure $assertion
        )
    }

    >> 'from test' {
      fails {
        fake-test-src |
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
        ])
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
    var assertion-reference = 'should-be-greater-than-ninety'

    var failure-description = 'Values that are <= 90'

    fn should-be-greater-than-ninety {
      assertion:enforce-predicate $assertion-reference { |value| > $value 90 } $failure-description
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
          $failure-description
        ]
    }

    >> 'when there are non-compliant values' {
      var failing-block = {
        all [
          7
          90
          92
          39
          95
        ] |
          should-be-greater-than-ninety
      }

      >> 'should fail' {
        assertion-fails $assertion-reference $failing-block
      }

      >> 'should output the non-compliant values' {
        var output = (
          capture &throws $failing-block
        )

        put $output |
          should-contain-snippet [
            $failure-description':'
            '['
            ' 7'
            ' 90'
            ' 39'
            ']'
          ]

        put $output |
          should-contain-none [
            92
            95
          ]
      }
    }

    >> 'getting string subject' {
      >> 'when the subject is a string' {
        put Dodo |
          assertion:get-string-subject |
          should-be Dodo
      }

      >> 'when the subject is not a string' {
        fails {
          put (num 90) |
            assertion:get-string-subject
        } |
          should-be 'The subject must be a string'
      }
    }

    >> 'enforcing string argument' {
      >> 'when the argument is a string' {
        assertion:enforce-string-argument Dodo
      }

      >> 'when the argument is not a string' {
        fails {
          assertion:enforce-string-argument (num 90)
        } |
          should-be 'The assertion argument must be a string'
      }
    }
  }
}