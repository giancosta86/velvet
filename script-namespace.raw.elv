use path
use str
use github.com/giancosta86/aurora-elvish/command
use github.com/giancosta86/aurora-elvish/exception
use ./describe-context
use ./describe-result
use ./assertions
use ./outcomes
use ./raw
use ./script-namespace

var test-script-path = (path:join (path:dir (src)[name]) tests relative alpha.elv)

fn create-test-controller {
  script-namespace:create-controller $test-script-path
}

raw:suite 'Script namespace controller upon creation' { |test~|
  test 'Retrieving the stats' {
    var namespace-controller = (create-test-controller)

    $namespace-controller[get-stats] |
      assertions:should-be [
        &total=0
        &passed=0
        &failed=0
      ]
  }

  test 'Retrieving the describe result' {
    var namespace-controller = (create-test-controller)

    $namespace-controller[to-result] |
      assertions:should-be [
        &test-results=[&]
        &sub-results=[&]
      ]
  }

  test 'Getting the first exception' {
    var namespace-controller = (create-test-controller)

    $namespace-controller[get-first-exception] |
      assertions:should-be $nil
  }
}

raw:suite 'Script namespace upon creation' { |test~|
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

  test 'Accessing the additional global functions' {
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
}

raw:suite 'Script namespace controller after running passing test' { |test~|
  fn run-passing-test {
    var namespace-controller = (create-test-controller)

    var namespace = $namespace-controller[namespace]

    $namespace[describe~] 'My description' {
      $namespace[it~] 'should work' {
        echo Wiii!
      }
    }

    put $namespace-controller
  }

  test 'Retrieving the stats' {
    var namespace-controller = (run-passing-test)

    $namespace-controller[get-stats] |
      assertions:should-be [
        &total=1
        &passed=1
        &failed=0
      ]
  }

  test 'Retrieving the describe result' {
    var namespace-controller = (run-passing-test)

    $namespace-controller[to-result] |
      assertions:should-be [
        &test-results= [&]
        &sub-results= [
          &'My description'=[
            &test-results=[
              &'should work'=[
                &outcome=$outcomes:passed
                &output="Wiii!\n"
                &status=$ok
              ]
            ]
            &sub-results=[&]
          ]
        ]
      ]
  }

  test 'Getting the first exception' {
    var namespace-controller = (run-passing-test)

    $namespace-controller[get-first-exception] |
      assertions:should-be $nil
  }
}


raw:suite 'Script namespace controller after running failing test' { |test~|
  fn run-failing-test {
    var namespace-controller = (create-test-controller)

    var namespace = $namespace-controller[namespace]

    $namespace[describe~] 'My description' {
      $namespace[it~] 'should fail' {
        echo Time to crash!
        fail DODO
      }
    }

    put $namespace-controller
  }

  test 'Retrieving the stats' {
    var namespace-controller = (run-failing-test)

    $namespace-controller[get-stats] |
      assertions:should-be [
        &total=1
        &passed=0
        &failed=1
      ]
  }

  test 'Retrieving the describe result' {
    var namespace-controller = (run-failing-test)

    $namespace-controller[to-result] |
      describe-result:simplify (all) |
      assertions:should-be [
        &test-results= [&]
        &sub-results= [
          &'My description'=[
            &test-results=[
              &'should fail'=[
                &outcome=$outcomes:failed
                &output="Time to crash!\n"
              ]
            ]
            &sub-results=[&]
          ]
        ]
      ]
  }

  test 'Getting the first exception' {
    var namespace-controller = (run-failing-test)

    $namespace-controller[get-first-exception] |
      exception:get-fail-message (all) |
      assertions:should-be DODO
  }
}


raw:suite 'Script namespace controller after running a passing and a failing test' { |test~|
  fn run-both-tests {
    var namespace-controller = (create-test-controller)

    var namespace = $namespace-controller[namespace]

    $namespace[describe~] 'My description' {
      $namespace[it~] 'should pass' {
        echo Wiii!
      }

      $namespace[describe~] 'Cip' {
        $namespace[describe~] 'Ciop' {
          $namespace[it~] 'should fail' {
            echo Wooo!
            fail DODUS
          }
        }
      }
    }

    put $namespace-controller
  }

  test 'Retrieving the stats' {
    var namespace-controller = (run-both-tests)

    $namespace-controller[get-stats] |
      assertions:should-be [
        &total=2
        &passed=1
        &failed=1
      ]
  }

  test 'Retrieving the describe result' {
    var namespace-controller = (run-both-tests)

    $namespace-controller[to-result] |
      describe-result:simplify (all) |
      assertions:should-be [
        &test-results= [&]
        &sub-results= [
          &'My description'=[
            &test-results=[
              &'should pass'=[
                &outcome=$outcomes:passed
                &output="Wiii!\n"
              ]
            ]
            &sub-results=[
              &Cip=[
                &test-results=[&]
                &sub-results=[
                  &Ciop=[
                    &test-results=[
                      &'should fail'=[
                        &outcome=$outcomes:failed
                        &output="Wooo!\n"
                      ]
                    ]
                    &sub-results=[&]
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
  }

  test 'Getting the first exception' {
    var namespace-controller = (run-both-tests)

    $namespace-controller[get-first-exception] |
      exception:get-fail-message (all) |
      assertions:should-be DODUS
  }
}