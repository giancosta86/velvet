use ../../resources

describe 'Loading resources from a nested script'  {
  it 'should return the content' {
    var resources = (resources:for-script (src))

    var alpha-path = ($resources[get-path] alpha.txt)

    var alpha-content = (slurp < $alpha-path)

    put $alpha-content |
      should-be "Hello!\n"
  }
}
