use ../../assertions
use ../../block-handlers
use ../../sandbox-result
use ../../section
use ../../summary
use ../../test-result

var should-contain~ = $assertions:should-contain~
var should-contain-all~ = $assertions:should-contain-all~
var should-contain-none~ = $assertions:should-contain-none~
var should-not-contain~ = $assertions:should-not-contain~

var capture~ = $block-handlers:capture~

fn run-console-tests { |settings|
  var '>>~' = $settings['>>~']

  var console-reporter = $settings[console-reporter]

  fn get-console-output { |sandbox-result|
    capture {
      summary:from-sandbox-result $sandbox-result |
        $console-reporter (all)
    }
  }

  fn run-sandbox-scenario { |sandbox-result scenario|
    var console-output = (
      get-console-output $sandbox-result
    )

    put $console-output |
      should-contain-all $scenario[all]

    put $console-output |
      should-contain-none $scenario[none]
  }

  >> 'with empty section' {
    run-sandbox-scenario $sandbox-result:empty $settings[scenarios][empty-section]
  }

  >> 'with single passed test' {
    var sandbox-result = (
      section:create [
        &Alpha=(
          test-result:success [Wiii!]
        )
      ] |
        sandbox-result:create (all)
    )

    run-sandbox-scenario $sandbox-result $settings[scenarios][single-passed-test]
  }

  >> 'with single failed test - having both output and exception lines' {
    var sandbox-result = (
      section:create [
        &Beta=(
          test-result:failure [Wooo!] [DODO]
        )
      ] |
        sandbox-result:create (all)
    )

    run-sandbox-scenario $sandbox-result $settings[scenarios][single-failed-having-output-and-exception]
  }

  >> 'with single failed test - having only output lines' {
    var sandbox-result = (
      section:create [
        &Beta=(
          test-result:failure [Wooo!] []
        )
      ] |
        sandbox-result:create (all)
    )

    run-sandbox-scenario $sandbox-result $settings[scenarios][single-failed-having-output-only]
  }

  >> 'with single failed test - having only exception lines' {
    var sandbox-result = (
      section:create [
        &Beta=(
          test-result:failure [] [DODO]
        )
      ] |
        sandbox-result:create (all)
    )

    run-sandbox-scenario $sandbox-result $settings[scenarios][single-failed-having-exception-only]
  }

  >> 'with multi-level tree' {
    var section = (
      section:create [
        &Alpha=(
          test-result:success [Wiii!]
        )
      ] [
        &SomeOther=(
          section:create [&] [
            &YetAnother=(
              section:create [
                &Beta=(
                  test-result:failure [Wooo!] [DODO]
                )
              ]
            )
          ]
        )
      ]
    )

    var sandbox-result = (
      sandbox-result:create $section
    )

    run-sandbox-scenario $sandbox-result $settings[scenarios][multi-level-tree]
  }

  >> 'when running just crashed scripts' {
    var sandbox-result = (
      sandbox-result:create $section:empty [
        &yogi.test.elv=[
          alpha
          beta
          gamma
        ]
        &bubu.test.elv=[
          ro
          sigma
        ]
      ]
    )

    var console-output = (
      get-console-output $sandbox-result
    )

    put $console-output |
      should-contain-all [
        'Total tests: 0'
        '⛔⛔⛔ CRASHED SCRIPTS'
        yogi.test.elv
        alpha
        bubu.test.elv
        ro
      ]

    put $console-output |
      should-contain-none [
        💬
        'No test structure found.'
      ]
  }
}