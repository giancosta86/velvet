describe 'Basic standalone test' {
  it 'should run' {
    echo 'Hello, world!'
  }

  describe 'in sub-describe' {
    it 'should work, too' {
      echo 'Wiiii!'
    }

    it 'should support yet another test' {
      echo 'Some more lines here'
    }
  }
}