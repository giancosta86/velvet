use ../assertion
use ./assertion-fails

var assertion-fails~ = $assertion-fails:assertion-fails~

>> 'Block handlers' {
  >> 'assertion-fails' {
    var expected-assertion = 'should-be-even'

    var actual-assertion = 'should-be-odd'

    >> 'when the expected assertion fails' {
      assertion-fails $expected-assertion {
        assertion:fail $expected-assertion
      }
    }

    >> 'when another assertion fails' {
      var mismatching-block = {
        assertion-fails $expected-assertion {
          assertion:fail $actual-assertion
        }
      }

      >> 'a failure should be thrown' {
        fails $mismatching-block |
          should-be 'Another assertion failed'
      }

      >> 'a contrast should be shown' {
        capture &throws $mismatching-block |
          should-contain-snippet [
            'Actual assertion:'
            $actual-assertion
            'Expected assertion:'
            $expected-assertion
          ]
      }
    }

    >> 'when a failure not induced by assertions occurs' {
      fails {
        assertion-fails $expected-assertion {
          fail DODO
        }
      } |
        should-be 'There was an exception, but not induced by an assertion'
    }

    >> 'when another exception occurs' {
      fails {
        assertion-fails $expected-assertion {
          / 9 0
        }
      } |
        should-be 'There was an exception, but not induced by an assertion'
    }

    >> 'when nothing fails' {
      fails {
        assertion-fails $expected-assertion { }
      } |
        should-be 'The given code block did not throw!'
    }

    >> 'when passing the result of src' {
      var fake-src-result = [
        &name='/some/test/'$expected-assertion'.test.elv'
      ]

      >> 'when the expected assertion fails' {
        assertion-fails $fake-src-result {
          assertion:fail $expected-assertion
        }
      }

      >> 'when another assertion fails' {
        capture &throws {
          assertion-fails $fake-src-result {
            assertion:fail $actual-assertion
          }
        } |
          should-contain-snippet [
            'Actual assertion:'
            $actual-assertion
            'Expected assertion:'
            $expected-assertion
          ]
      }
    }
  }
}