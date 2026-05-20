use os
use str

>> 'The script source' {
  var script-src = (src)

  >> 'should be a file' {
    put $script-src[is-file] |
      should-be $true
  }

  >> 'should contain the script path' {
    put $script-src[name] |
      should-have-suffix metainfo.test.elv
  }

  >> 'should contain the source code' {
    put $script-src[code] |
      should-contain 'should contain the source code'
  }
}

>> 'The provided functions' {
  >> 'should be available' {
    all [
      $'>>~'
      $throws~
      $should-be~
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

>> 'The provided tools' {
  >> 'should be available' {
    fails {
      fail-test
    } |
      should-be 'TEST SET TO FAIL'
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