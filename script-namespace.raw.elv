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

  test 'Accessing the global functions' {
    var namespace-controller = (create-test-controller)

    var namespace = $namespace-controller[namespace]

    all [
      describe
      it
      assert
      expect-crash
      fail-test
      should-be
    ] | each { |name|
      kind-of $namespace[$name'~'] |
        assertions:should-be 'fn'
    }
  }

  test 'Getting the first exception' {
    var namespace-controller = (create-test-controller)

    $namespace-controller[get-first-exception] |
      assertions:should-be $nil
  }
}