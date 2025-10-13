use str

describe 'In arithmetic' {
  describe 'addition' {
    it 'should work' {
      + 89 1 |
        should-be 90
    }
  }

  describe 'multiplication' {
    it 'should return just the expected value' {
      var result = (* 15 6)

      put $result |
        should-be 90

      put $result |
        should-not-be 12
    }
  }

  describe 'division' {
    describe 'when dividing by 0' {
      it 'should fail' {
        expect-throws {
          / 92 0
        } |
          to-string (all)[reason] |
          str:contains (all) divisor |
          should-be $true
      }
    }
  }
}