use str

describe 'Arithmetic' {
  describe 'addition' {
    it 'should work' {
      echo Testing addition...

      + 90 2 |
        should-be 92
    }
  }

  describe 'division' {
    it 'should work' {
      / 90 10 |
        should-be (num 9)
    }

    describe 'when dividing by zero' {
      it 'should fail with no subsequent check' {
        expect-crash {
          / 98 0
        }
      }

      it 'should fail with subsequent check' {
        expect-crash {
          / 98 0
        } |
          to-string (all)[reason] |
          str:contains (all) divisor |
          should-be $true
      }
    }
  }
}