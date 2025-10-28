use str

>> 'In arithmetic' {
  >> 'addition' {
    >> 'should work' {
      + 89 1 |
        should-be 90
    }
  }

  >> 'multiplication' {
    >> 'should return just the expected value' {
      var result = (* 15 6)

      put $result |
        should-be 90

      put $result |
        should-not-be 12
    }
  }

  >> 'division' {
    >> 'when dividing by 0' {
      >> 'should fail' {
        expect-throws {
          / 92 0
        } |
          to-string (all)[reason] |
          str:contains (all) divisor |
          should-be $true
      }
    }
  }

  >> 'custom fail' {
    >> 'should be handled and inspectable' {
      expect-throws {
        if (== (% 8 2) 0) {
          fail '8 is even!'
        }
      } |
        get-fail-message |
        should-be '8 is even!'
    }
  }
}