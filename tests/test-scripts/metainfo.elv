use str
use ../../utils/lang

describe 'The script source' {
  var script-src = (src)

  it 'should be a file' {
    put $script-src[is-file] |
      should-be $true
  }

  it 'should contain the script path' {
    put $script-src[name] |
      str:contains (all) metainfo.elv |
      should-be $true
  }

  it 'should contain the source code' {
    put $script-src[code] |
      str:contains (all) 'should contain the source code' |
      should-be $true
  }
}

describe 'The provided functions' {
  it 'should be available' {
    all [
      $describe~
      $it~
      $assert~
      $expect-crash~
      $fail-test~
      $should-be~
    ] | each { |provided-fn|
      lang:is-function $provided-fn |
        should-be $true
    }
  }
}