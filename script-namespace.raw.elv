use path
use str
use github.com/giancosta86/aurora-elvish/command
use github.com/giancosta86/aurora-elvish/exception
use ./describe-context
use ./assertions
use ./raw
use ./script-namespace

raw:suite 'Script namespace controller upon creation' { |test~|
  var test-script-path = (path:join (path:dir (src)[name]) tests relative alpha.elv)

  fn create-test-controller {
    script-namespace:create-controller $test-script-path
  }

  test 'Retrieving the stats' {
    var namespace-controller = (create-test-controller)

    $namespace-controller[get-stats] |
      assertions:should-be [
        &total=0
        &passed=0
        &failed=0
      ]
  }

  test 'Retrieving the result context' {
    var namespace-controller = (create-test-controller)

    $namespace-controller[to-result-context] |
      assertions:should-be [
        &tests=[&]
        &sub-contexts=[&]
      ]
  }

  test 'Calling src from the namespace' {
    var namespace-controller = (create-test-controller)

    var namespace = $namespace-controller[namespace]

    var namespace-src = ($namespace[src~])

    put $namespace-src[is-file] |
      assertions:should-be $true

    put $namespace-src[name] |
      assertions:should-be $test-script-path

    str:trim-space $namespace-src[code] |
      str:contains (all) 'use-mod' |
      assertions:should-be $true
  }

  test 'Calling a function from the enriched namespace' {
    var namespace-controller = (create-test-controller)

    var namespace = $namespace-controller[namespace]

    $namespace[safe~] |
      assertions:should-be 92
  }

  test 'Importing a relative module from within the namespace' {
    var namespace-controller = (create-test-controller)

    var namespace = $namespace-controller[namespace]

    $namespace[with-use~] |
      assertions:should-be 95
  }

  test 'Calling use-mod from within the namespace' {
    var namespace-controller = (create-test-controller)

    var namespace = $namespace-controller[namespace]

    $namespace[with-use-mod~] |
      assertions:should-be 98
  }
}