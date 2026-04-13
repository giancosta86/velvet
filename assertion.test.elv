use ./assertion

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
}