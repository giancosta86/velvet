use os
use str

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
      $'>>~'
      $throws~
      $fail-test~
      $get-fail-content~
      $should-be~
      $should-not-be~
      $should-emit~
      $should-contain~
    ] | each { |provided-fn|
      lang:is-function $provided-fn |
        should-be $true
    }
  }
}

>> 'The namespaces from Ethereal' {
  >> 'should be available' {
    all [2 3 5] |
      seq:reduce 90 $'+~' |
      should-be 100
  }
}

>> 'Redirection - appending to file' {
  >> 'should work' {
    fs:with-temp-file { |temp-path|
      echo alpha >> $temp-path
      echo beta >> $temp-path

      slurp < $temp-path |
        should-be "alpha\nbeta\n"
    }
  }
}