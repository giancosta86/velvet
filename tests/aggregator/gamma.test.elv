describe 'In gamma' {
  it 'should pass' {
    echo Gamma 3
  }
}

describe 'In beta' {
  it 'is duplicated' {
    echo Beta 4
  }
}

describe 'In alpha' {
  it 'should work too' {
    echo Alpha 5
  }

  describe 'In sub-level' {
    it 'should fail' {
      fail 'DODO'
    }
  }
}