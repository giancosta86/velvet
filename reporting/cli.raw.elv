use str
use ../assertions
use ../outcomes
use ../section
use ../stats
use ../utils/raw
use ./cli

raw:suite 'Command-line reporting' { |test~|
  fn create-output-tester { |section|
    var stats = (stats:from-section $section)

    var report-output = (cli:display $section $stats | slurp)

    put [
      &expect-in-output={ |snippets|
        all $snippets | each { |snippet|
          str:contains $report-output $snippet |
            assertions:should-be $true
        }
      }

      &expect-not-in-output={ |snippets|
        all $snippets | each { |snippet|
          str:contains $report-output $snippet |
            assertions:should-be $false
        }
      }
    ]
  }

  test 'With empty section' {
    var output-tester = (create-output-tester $section:empty)

    $output-tester[expect-in-output] [
      💬
      No test structure found.
    ]

    $output-tester[expect-not-in-output] [
      LOG
    ]
  }

  test 'With single passed test' {
    var section = [
      &test-results=[
        &Alpha=[
          &outcome=$outcomes:passed
          &output="Wiii!\n"
          &exception-log=$nil
        ]
      ]
      &sub-sections=[&]
    ]

    var output-tester = (create-output-tester $section)

    $output-tester[expect-in-output] [
      Alpha
      ✅
      'Total tests: 1.'
    ]

    $output-tester[expect-not-in-output] [
      'Passed: 1.'
      'Failed: 0.'
      Wiii!
      LOG
    ]
  }

  test 'With single failed test - having output' {
    var section = [
      &test-results=[
        &Beta=[
          &outcome=$outcomes:failed
          &output="Wooo!\n"
          &exception-log=DODO
        ]
      ]
      &sub-sections=[&]
    ]

    var output-tester = (create-output-tester $section)

    $output-tester[expect-in-output] [
      ❌
      'OUTPUT LOG'
      'EXCEPTION LOG'
      Wooo!
      DODO
      'Total tests: 1.'
      'Passed: 0.'
      'Failed: 1.'
    ]
  }

  test 'With single failed test - having no output' {
    var section = [
      &test-results=[
        &Beta=[
          &outcome=$outcomes:failed
          &output=""
          &exception-log=DODO
        ]
      ]
      &sub-sections=[&]
    ]

    var output-tester = (create-output-tester $section)

    $output-tester[expect-in-output] [
      ❌
      'EXCEPTION LOG'
      DODO
      'Total tests: 1.'
      'Passed: 0.'
      'Failed: 1.'
    ]

    $output-tester[expect-not-in-output] [
      'OUTPUT LOG'
    ]
  }

  test 'With multi-level describe result' {
    var section = [
      &test-results=[
        &Alpha=[
          &outcome=$outcomes:passed
          &output="Wiii!\n"
          &exception-log=$nil
        ]
      ]
      &sub-sections=[
        &SomeOther=[
          &test-results=[&]
          &sub-sections=[
            &YetAnother=[
              &test-results=[
                &Beta=[
                  &outcome=$outcomes:failed
                  &output="Wooo!\n"
                  &exception-log=DODO
                ]
              ]
              &sub-sections=[&]
            ]
          ]
        ]
      ]
    ]

    var output-tester = (create-output-tester $section)

    $output-tester[expect-in-output] [
      Alpha
      ❌
      LOG
      Beta
      Wooo!
      DODO
      'Total tests: 2.'
      'Passed: 1.'
      'Failed: 1.'
    ]

    $output-tester[expect-not-in-output] [
      Wiii!
    ]
  }
}