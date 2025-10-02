describe 'In gamma' {
  it 'should pass' {
    echo Gamma 3
  }
}

describe 'In beta' {
  it 'is duplicated in third source file' {
    echo Beta 4
  }
}

describe 'In alpha' {
  it 'should work too' {
    echo Alpha 5
    put 90
  }

  describe 'In sub-level' {
    it 'should fail' {
      echo Cip
      echo Ciop >&2

      fail 'DODO'
    }
  }
}