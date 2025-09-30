use str
use ../assertions
use ../outcomes
use ../stats
use ../utils/raw
use ./cli

raw:suite 'CLI reporting' { |test~|
  fn create-output-tester { |describe-result|
    var stats = (stats:from-describe-result $describe-result)

    var output = (cli:display $describe-result $stats | slurp)

    put [
      &expect-in-output={ |snippets|
        all $snippets | each { |snippet|
          str:contains $output $snippet |
            assertions:should-be $true
        }
      }

      &expect-not-in-output={ |snippets|
        all $snippets | each { |snippet|
          str:contains $output $snippet |
            assertions:should-be $false
        }
      }
    ]
  }

  test 'With empty describe result' {
    var describe-result = [
      &test-results=[&]
      &sub-results=[&]
    ]

    var stats = (stats:from-describe-result $describe-result)

    cli:display $describe-result $stats |
      assertions:should-be '💬 No test structure found.'
  }

  test 'With single passed test' {
    var describe-result = [
      &test-results=[
        &Alpha=[
          &outcome=$outcomes:passed
          &output="Wiii!\n"
          &exception-log=$nil
        ]
      ]
      &sub-results=[&]
    ]

    var output-tester = (create-output-tester $describe-result)

    $output-tester[expect-in-output] [
      Alpha
      ✅
      'Total tests: 1.'
      'Passed: 1.'
      'Failed: 0.'
    ]

    $output-tester[expect-not-in-output] [
      Wiii!
    ]
  }

  test 'With single failed test' {
    var describe-result = [
      &test-results=[
        &Beta=[
          &outcome=$outcomes:failed
          &output="Wooo!\n"
          &exception-log=DODO
        ]
      ]
      &sub-results=[&]
    ]

    var output-tester = (create-output-tester $describe-result)

    $output-tester[expect-in-output] [
      ❌
      Wooo!
      DODO
      'Total tests: 1.'
      'Passed: 0.'
      'Failed: 1.'
    ]
  }

  test 'With multi-level describe result' {
    var describe-result = [
      &test-results=[
        &Alpha=[
          &outcome=$outcomes:passed
          &output="Wiii!\n"
          &exception-log=$nil
        ]
      ]
      &sub-results=[
        &SomeOther=[
          &test-results=[&]
          &sub-results=[
            &YetAnother=[
              &test-results=[
                &Beta=[
                  &outcome=$outcomes:failed
                  &output="Wooo!\n"
                  &exception-log=DODO
                ]
              ]
              &sub-results=[&]
            ]
          ]
        ]
      ]
    ]

    var output-tester = (create-output-tester $describe-result)

    $output-tester[expect-in-output] [
      Alpha
      ❌
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