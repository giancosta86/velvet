describe 'My description' {
  it 'should fail' {
    echo Wooo!
    echo Wooo2! >&2
    put 90

    fail DODO
  }
}