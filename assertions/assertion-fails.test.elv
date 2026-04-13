use ../assertion
use ./assertion-fails

var assertion-fails~ = $assertion-fails:assertion-fails~

>> 'Expecting assertion failure' {
  var expected-assertion = 'should-not-exist'

  var actual-assertion = 'should-contain'

  >> 'when the expected assertion fails' {
    assertion-fails $expected-assertion {
      assertion:fail $expected-assertion
    }
  }

  >> 'when another assertion fails' {
    var mismatching-block = {
      assertion-fails $expected-assertion {
        assertion:format-failure $actual-assertion |
          fail (all)
      }
    }

    >> 'a failure should be thrown' {
      fails $mismatching-block |
        should-be 'Another assertion failed'
    }

    >> 'a contrast should be shown' {
      var output-tester = (
        throws &swallow $mismatching-block |
          create-output-tester &unstyled
      )

      $output-tester[should-contain-snippet] [
        'Expected assertion:'
        $expected-assertion
        'Actual assertion:'
        $actual-assertion
      ]
    }
  }

  >> 'when a failure not induced by assertions occurs' {
    fails {
      assertion-fails 'should-be-ninety' {
        fail DODO
      }
    } |
      should-be 'There was an exception, but not induced by an assertion'
  }

  >> 'when nothing fails' {
    fails {
      assertion-fails $expected-assertion { }
    } |
      should-be 'The given code block did not fail!'
  }

  >> 'when passing the result of src' {
    var assertion-name = 'should-be-ninety'

    var fake-src-result = [
      &name='/some/test/'$assertion-name'.test.elv'
    ]

    assertion-fails $fake-src-result {
      assertion:fail $fake-src-result
    }
  }
}