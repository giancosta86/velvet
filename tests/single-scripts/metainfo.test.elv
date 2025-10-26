use os
use str
use ../../utils/fs
use ../../utils/lang

>> The script source {
  var script-src = (src)

  >> should be a file {
    put $script-src[is-file] |
      should-be $true
  }

  >> should contain the script path {
    str:has-suffix $script-src[name] metainfo.test.elv |
      should-be $true
  }

  >> should contain the source code {
    put $script-src[code] |
      str:contains (all) 'should contain the source code' |
      should-be $true
  }
}

>> The provided functions {
  >> should be available {
    all [
      $'>>~'
      $expect-throws~
      $fail-test~
      $get-fail-message~
      $should-be~
      $should-not-be~
    ] | each { |provided-fn|
      lang:is-function $provided-fn |
        should-be $true
    }
  }
}

>> Redirection - appending to file {
  >> should work {
    var temp-path = (fs:temp-file-path)
    defer { os:remove $temp-path }

    echo alpha >> $temp-path
    echo beta >> $temp-path

    slurp < $temp-path |
      should-be "alpha\nbeta\n"
  }
}