use str
use ./outcomes
use ./section
use ./test-result
use ./test-script-frame

fn create-test-frame { |title|
  test-script-frame:create 'fake-script.elv' $title
}

>> 'Frame - Running a block' {
  var block = {
    echo Wiii!
  }

  >> 'once' {
    var alpha = (create-test-frame 'alpha')

    $alpha[run-block] $block
  }

  >> 'twice' {
    var alpha = (create-test-frame 'alpha')

    $alpha[run-block] $block

    throws {
      $alpha[run-block] $block
    } |
      get-fail-content |
      should-be 'Block result already set in frame: alpha'
  }
}

>> 'Frame - Converting to artifact' {
  >> 'with no block' {
    var alpha = (create-test-frame 'alpha')

    throws {
      $alpha[to-artifact]
    } |
      get-fail-content |
      should-be 'Cannot obtain artifact when block result is not set, in frame: alpha'
  }

  >> 'with empty test' {
    var alpha = (create-test-frame 'alpha')

    $alpha[run-block] { }

    $alpha[to-artifact] |
      should-be [
        &output=''
        &outcome=$outcomes:passed
        &exception-log=$nil
      ]
  }

  >> 'with passing test' {
    var alpha = (create-test-frame 'alpha')

    $alpha[run-block] {
      echo Wiii!
      echo Wiii2! >&2
      put 90
    }

    var test-result = ($alpha[to-artifact])

    put $test-result |
      should-be [
        &output="Wiii!\nWiii2!\n"
        &outcome=$outcomes:passed
        &exception-log=$nil
      ]
  }

  >> 'with failing test' {
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
      should-be [
        &output="Wooo\nWooo2\n"
        &outcome=$outcomes:failed
      ]

    str:contains $test-result[exception-log] 'Dodo' |
      should-be $true
  }

  >> 'with section having passing test' {
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
      should-be [
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

  >> 'with section having failing test' {
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
      should-be [
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
      should-be $true
  }

  >> 'with section having passing and failing test' {
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
      should-be [
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

  >> 'with section having duplicate passing test' {
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
      should-be [
        &test-results=[
          &beta=$test-result:duplicate
        ]
        &sub-sections=[&]
      ]
  }

  >> 'with section whose sub-sections have the same name' {
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
      should-be [
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

  >> 'with section having multi-level tests' {
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
      should-be [
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
      should-be $true
  }
}