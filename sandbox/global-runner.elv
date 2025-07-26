use path
use github.com/giancosta86/aurora-elvish/fs
use ../namespace

fn -run-file { |&fail-fast=$false source-path test-namespace|
  var source-string = (slurp < $source-path)

  tmp pwd = (path:dir $source-path)

  eval &ns=$test-namespace $source-string
}

fn run-tests { |inputs|
  var includes = $inputs[includes]
  var excludes = $inputs[excludes]
  var fail-fast = $inputs[fail-fast]

  var namespace-controller = (namespace:create &fail-fast=$fail-fast)

  fs:wildcard $includes &excludes=$excludes |
    each { |wildcard-test-file-path|
      var test-file-path = (path:abs $wildcard-test-file-path)

      $namespace-controller[set-current-source-path] $test-file-path

      -run-file &fail-fast=$fail-fast $test-file-path $namespace-controller[namespace]
    }

  put [
    &stats=($namespace-controller[get-stats])
    &outcome-map=($namespace-controller[get-outcome-map])
  ]
}
