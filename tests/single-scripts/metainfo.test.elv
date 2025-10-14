use str
use ../../utils/lang

>> 'The script source' {
  var script-src = (src)

  >> 'should be a file' {
    put $script-src[is-file] |
      should-be $true
  }

  >> 'should contain the script path' {
    str:has-suffix $script-src[name] metainfo.test.elv |
      should-be $true
  }

  >> 'should contain the source code' {
    put $script-src[code] |
      str:contains (all) 'should contain the source code' |
      should-be $true
  }
}

>> 'The provided functions' {
  >> 'should be available' {
    all [
      $describe~
      $it~
      $expect-throws~
      $fail-test~
      $should-be~
      $should-not-be~
    ] | each { |provided-fn|
      lang:is-function $provided-fn |
        should-be $true
    }
  }
}