use str
use ../outcomes
use ../section
use ../test-result
use ./frame

var passing-block = {
  echo Wiii
  sleep 1ms
  echo Wiii2 >&2
  put 90
}

var failing-block = {
  echo Wooo
  sleep 1ms
  echo Wooo2 >&2
  put 90
  fail Dodo
}

fn create-test-frame { |title|
  frame:create 'fake-script.elv' $title
}

>> 'Test script frame' {
  >> 'running a block' {
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

      fails {
        $alpha[run-block] $block
      } |
        should-be 'Block result already set in frame: alpha'
    }
  }

  >> 'converting to artifact' {
    >> 'with no block' {
      var alpha = (create-test-frame 'alpha')

      fails {
        $alpha[to-artifact]
      } |
        should-be 'Cannot obtain artifact when block result is not set, in frame: alpha'
    }

    >> 'with empty test' {
      var alpha = (create-test-frame 'alpha')

      $alpha[run-block] { }

      $alpha[to-artifact] |
        should-be (test-result:success [])
    }

    >> 'with passed test' {
      var alpha = (create-test-frame 'alpha')

      $alpha[run-block] $passing-block

      var test-result = ($alpha[to-artifact])

      put $test-result |
        should-be (test-result:success [Wiii Wiii2])
    }

    >> 'with failed test' {
      var alpha = (create-test-frame 'alpha')

      $alpha[run-block] $failing-block

      var test-result = ($alpha[to-artifact])

      test-result:simplify $test-result |
        should-be (test-result:failure [Wooo Wooo2] [])

      all $test-result[exception-lines] |
        str:join "\n" |
        should-contain Dodo
    }

    >> 'with section having passed test' {
      var alpha = (create-test-frame 'alpha')

      $alpha[run-block] {
        var beta = (create-test-frame 'beta')
        $alpha[add-sub-frame] $beta

        $beta[run-block] $passing-block
      }

      $alpha[to-artifact] |
        should-be (
          section:create [
            &beta=(
              test-result:success [Wiii Wiii2]
            )
          ]
        )
    }

    >> 'with section having failed test' {
      var alpha = (create-test-frame 'alpha')

      $alpha[run-block] {
        var beta = (create-test-frame 'beta')
        $alpha[add-sub-frame] $beta

        $beta[run-block] $failing-block
      }

      var section = ($alpha[to-artifact])

      put $section |
        section:simplify |
        should-be (
          section:create [
            &beta=(
              test-result:failure [Wooo Wooo2] []
            )
          ]
        )

      all $section[test-results][beta][exception-lines] |
        str:join "\n" |
        should-contain Dodo
    }

    >> 'with section having both passing and failing test' {
      var alpha = (create-test-frame 'alpha')

      $alpha[run-block] {
        var beta = (create-test-frame 'beta')
        $alpha[add-sub-frame] $beta
        $beta[run-block] $passing-block

        var gamma = (create-test-frame 'gamma')
        $alpha[add-sub-frame] $gamma
        $gamma[run-block] $failing-block
      }

      $alpha[to-artifact] |
        section:simplify |
        should-be (
          section:create [
            &beta=(
              test-result:success [Wiii Wiii2]
            )
            &gamma=(
              test-result:failure [Wooo Wooo2] []
            )
          ]
        )
    }

    >> 'with section having duplicate passing test' {
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
        should-be (
          section:create [
            &beta=$test-result:duplicate-test
          ]
        )
    }

    >> 'with section whose sub-sections have the same name' {
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

          $delta[run-block] $failing-block
        }
      }

      $alpha[to-artifact] |
        section:simplify |
        should-be (
          section:create [&] [
            &beta=(
              section:create [
                &gamma=(
                  test-result:success [Wiii Wiii2]
                )
                &delta=(
                  test-result:failure [Wooo Wooo2] []
                )
              ]
            )
          ]
        )
    }

    >> 'with multi-level tests' {
      var alpha = (create-test-frame 'alpha')

      $alpha[run-block] {
        var beta = (create-test-frame 'beta')
        $alpha[add-sub-frame] $beta
        $beta[run-block] {
          echo Beta
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
              echo Epsilon
            }

            var zeta = (create-test-frame 'zeta')
            $delta[add-sub-frame] $zeta
            $zeta[run-block] {
              echo Zeta
              fail Dodo
            }
          }
        }
      }

      var section = ($alpha[to-artifact])

      section:simplify $section |
        should-be (
          section:create [
            &beta=(
              test-result:success [Beta]
            )
          ] [
            &gamma=(
              section:create [&] [
                &delta=(
                  section:create [
                    &epsilon=(
                      test-result:success [Epsilon]
                    )
                    &zeta=(
                      test-result:failure [Zeta] []
                    )
                  ]
                )
              ]
            )
          ]
        )

      put $section[sub-sections][gamma] |
        put (all)[sub-sections][delta] |
        put (all)[test-results][zeta] |
        all (all)[exception-lines] |
        str:join "\n" |
        should-contain Dodo
    }
  }
}