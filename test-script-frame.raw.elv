use str
use ./assertions
use ./outcomes
use ./section
use ./test-result
use ./test-script-frame
use ./utils/exception
use ./utils/raw

fn create-test-frame { |title|
  test-script-frame:create 'fake-script.elv' $title
}

raw:suite 'Frame - Running a block' { |test~|
  var block = {
    echo Wiii!
  }

  test 'Once' {
    var alpha = (create-test-frame 'alpha')

    $alpha[run-block] $block
  }

  test 'Twice' {
    var alpha = (create-test-frame 'alpha')

    $alpha[run-block] $block

    exception:throws {
      $alpha[run-block] $block
    } |
      exception:get-fail-message |
      assertions:should-be 'Block result already set in frame: alpha'
  }
}

raw:suite 'Frame - Converting to artifact' { |test~|
  test 'With no block' {
    var alpha = (create-test-frame 'alpha')

    exception:throws {
      $alpha[to-artifact]
    } |
      exception:get-fail-message |
      assertions:should-be 'Cannot obtain artifact when block result is not set, in frame: alpha'
  }

  test 'With empty test' {
    var alpha = (create-test-frame 'alpha')

    $alpha[run-block] { }

    $alpha[to-artifact] |
      assertions:should-be [
        &output=''
        &outcome=$outcomes:passed
        &exception-log=$nil
      ]
  }

  test 'With passing test' {
    var alpha = (create-test-frame 'alpha')

    $alpha[run-block] {
      echo Wiii!
      echo Wiii2! >&2
      put 90
    }

    var test-result = ($alpha[to-artifact])

    put $test-result |
      assertions:should-be [
        &output="Wiii!\nWiii2!\n"
        &outcome=$outcomes:passed
        &exception-log=$nil
      ]
  }

  test 'With failing test' {
    var alpha = (create-test-frame 'alpha')

    $alpha[run-block] {
      echo Wooo
      echo Wooo2 >&2
      put 90
      fail Dodo
    }

    var test-result = ($alpha[to-artifact])

    put $test-result |
      test-result:simplify (all) |
      assertions:should-be [
        &output="Wooo\nWooo2\n"
        &outcome=$outcomes:failed
      ]

    str:contains $test-result[exception-log] 'Dodo' |
      assertions:should-be $true
  }

  test 'With section having passing test' {
    var alpha = (create-test-frame 'alpha')

    $alpha[run-block] {
      var beta = (create-test-frame 'beta')
      $alpha[add-sub-frame] $beta

      $beta[run-block] {
        echo Wiii!
        echo Wiii2! >&2
        put 90
      }
    }

    var section = ($alpha[to-artifact])

    put $section |
      assertions:should-be [
        &test-results=[
          &beta=[
            &output="Wiii!\nWiii2!\n"
            &outcome=$outcomes:passed
            &exception-log=$nil
          ]
        ]
        &sub-sections=[&]
      ]
  }

  test 'With section having failing test' {
    var alpha = (create-test-frame 'alpha')

    $alpha[run-block] {
      var gamma = (create-test-frame 'gamma')
      $alpha[add-sub-frame] $gamma

      $gamma[run-block] {
        echo Wooo
        echo Wooo2 >&2
        put 90
        fail Dodo
      }
    }

    var section = ($alpha[to-artifact])

    section:simplify $section |
      assertions:should-be [
        &test-results=[
          &gamma=[
            &output="Wooo\nWooo2\n"
            &outcome=$outcomes:failed
          ]
        ]
        &sub-sections=[&]
      ]

    put $section[test-results][gamma][exception-log] |
      str:contains (all) 'Dodo' |
      assertions:should-be $true
  }

  test 'With section having passing and failing test' {
    var alpha = (create-test-frame 'alpha')

    $alpha[run-block] {
      var beta = (create-test-frame 'beta')
      $alpha[add-sub-frame] $beta

      $beta[run-block] {
        echo Wiii!
        echo Wiii2! >&2
        put 90
      }

      var gamma = (create-test-frame 'gamma')
      $alpha[add-sub-frame] $gamma

      $gamma[run-block] {
        echo Wooo
        echo Wooo2 >&2
        put 90
        fail Dodo
      }
    }

    var section = ($alpha[to-artifact])

    section:simplify $section |
      assertions:should-be [
        &test-results=[
          &beta=[
            &output="Wiii!\nWiii2!\n"
            &outcome=$outcomes:passed
          ]
          &gamma=[
            &output="Wooo\nWooo2\n"
            &outcome=$outcomes:failed
          ]
        ]
        &sub-sections=[&]
      ]
  }

  test 'With section having duplicate passing test' {
    var passing-block = {
      echo Wiii!
      echo Wiii2! >&2
      put 90
    }

    var alpha = (create-test-frame 'alpha')

    $alpha[run-block] {
      var beta = (create-test-frame 'beta')
      $alpha[add-sub-frame] $beta
      $beta[run-block] $passing-block

      var beta-bis = (create-test-frame 'beta')
      $alpha[add-sub-frame] $beta-bis
      $beta-bis[run-block] $passing-block
    }

    $alpha[to-artifact] |
      assertions:should-be [
        &test-results=[
          &beta=$test-result:duplicate
        ]
        &sub-sections=[&]
      ]
  }

  test 'With section whose sub-sections have the same name' {
    var passing-block = {
      echo Wiii!
      echo Wiii2! >&2
      put 90
    }

    var alpha = (create-test-frame 'alpha')

    $alpha[run-block] {
      var beta = (create-test-frame 'beta')
      $alpha[add-sub-frame] $beta

      $beta[run-block] {
        var gamma = (create-test-frame 'gamma')
        $beta[add-sub-frame] $gamma

        $gamma[run-block] $passing-block
      }

      var beta-bis = (create-test-frame 'beta')
      $alpha[add-sub-frame] $beta-bis

      $beta-bis[run-block] {
        var delta = (create-test-frame 'delta')
        $beta-bis[add-sub-frame] $delta

        $delta[run-block] $passing-block
      }
    }

    $alpha[to-artifact] |
      assertions:should-be [
        &test-results=[&]
        &sub-sections=[
          &beta=[
            &test-results=[
              &gamma=[
                &output="Wiii!\nWiii2!\n"
                &outcome=$outcomes:passed
                &exception-log=$nil
              ]
              &delta=[
                &output="Wiii!\nWiii2!\n"
                &outcome=$outcomes:passed
                &exception-log=$nil
              ]
            ]
            &sub-sections=[&]
          ]
        ]
      ]
  }

  test 'With section having multi-level tests' {
    var alpha = (create-test-frame 'alpha')

    $alpha[run-block] {
      var beta = (create-test-frame 'beta')
      $alpha[add-sub-frame] $beta

      $beta[run-block] {
        echo Beta!
      }

      var gamma = (create-test-frame 'gamma')
      $alpha[add-sub-frame] $gamma

      $gamma[run-block] {
        var delta = (create-test-frame 'delta')
        $gamma[add-sub-frame] $delta

        $delta[run-block] {
          var epsilon = (create-test-frame 'epsilon')
          $delta[add-sub-frame] $epsilon

          $epsilon[run-block] {
            echo Epsilon!
          }

          var zeta = (create-test-frame 'zeta')
          $delta[add-sub-frame] $zeta

          $zeta[run-block] {
            echo Zeta!
            fail DODO
          }
        }
      }
    }

    var section = ($alpha[to-artifact])

    section:simplify $section |
      assertions:should-be [
        &test-results=[
          &beta=[
            &output="Beta!\n"
            &outcome=$outcomes:passed
          ]
        ]
        &sub-sections=[
          &gamma=[
            &test-results=[&]
            &sub-sections=[
              &delta=[
                &test-results=[
                  &epsilon=[
                    &output="Epsilon!\n"
                    &outcome=$outcomes:passed
                  ]
                  &zeta=[
                    &output="Zeta!\n"
                    &outcome=$outcomes:failed
                  ]
                ]
                &sub-sections=[&]
              ]
            ]

          ]
        ]
      ]

    put $section[sub-sections][gamma] |
      put (all)[sub-sections][delta] |
      put (all)[test-results][zeta] |
      put (all)[exception-log] |
      str:contains (all) DODO |
      assertions:should-be $true
  }
}