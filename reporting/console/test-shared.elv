use ../../sandbox-result
use ../../section
use ../../summary
use ../../test-result
use ../../tools/output-tester

fn run-console-tests { |settings|
  var '>>~' = $settings['>>~']

  var console-reporter = $settings[console-reporter]

  fn create-console-output-tester { |sandbox-result|
    summary:from-sandbox-result $sandbox-result |
      $console-reporter (all) |
      output-tester:create
  }

  fn run-sandbox-scenario { |sandbox-result scenario|
    var output-tester = (create-console-output-tester $sandbox-result)

    $output-tester[should-contain-all] $scenario[all]

    $output-tester[should-contain-none] $scenario[none]
  }

  >> 'with empty section' {
    run-sandbox-scenario $sandbox-result:empty $settings[scenarios][empty-section]
  }

  >> 'with single passed test' {
    var sandbox-result = [
      &section=(
        section:create [
          &Alpha=(
            test-result:success [Wiii!]
          )
        ]
      )
      &crashed-scripts=[&]
    ]

    run-sandbox-scenario $sandbox-result $settings[scenarios][single-passed-test]
  }

  >> 'with single failed test - having both output and exception lines' {
    var sandbox-result = [
      &section=(
        section:create [
          &Beta=(
            test-result:failure [Wooo!] [DODO]
          )
        ]
      )
      &crashed-scripts=[&]
    ]

    run-sandbox-scenario $sandbox-result $settings[scenarios][single-failed-having-output-and-exception]
  }

  >> 'with single failed test - having only output lines' {
    var sandbox-result = [
      &section=(
        section:create [
          &Beta=(
            test-result:failure [Wooo!] []
          )
        ]
      )
      &crashed-scripts=[&]
    ]

    run-sandbox-scenario $sandbox-result $settings[scenarios][single-failed-having-output-only]
  }

  >> 'with single failed test - having only exception lines' {
    var sandbox-result = [
      &section=(
        section:create [
          &Beta=(
            test-result:failure [] [DODO]
          )
        ]
      )
      &crashed-scripts=[&]
    ]

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

    var sandbox-result = [
      &section=$section
      &crashed-scripts=[&]
    ]

    run-sandbox-scenario $sandbox-result $settings[scenarios][multi-level-tree]
  }

  >> 'when running just crashed scripts' {
    var output-tester = (create-console-output-tester [
      &section=$section:empty
      &crashed-scripts=[
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
    ])

    $output-tester[should-contain-all] [
      'Total tests: 0'
      '⛔⛔⛔ CRASHED SCRIPTS'
      yogi.test.elv
      alpha
      bubu.test.elv
      ro
    ]

    $output-tester[should-contain-none] [
      💬
      'No test structure found.'
    ]
  }
}