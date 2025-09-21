describe 'In beta' {
  it 'is duplicated' {
    echo Beta 2
  }
}

describe 'In alpha' {
  describe 'In sub-level' {
    describe 'In sub-sub-level' {
      it 'should be ok' {
        echo "Alpha X" >&2
      }
    }
  }
}