use path
use str
use ../aggregator
use ../assertions
use ../outcomes
use ../raw
use ../stats
use ./cli

raw:suite 'CLI reporting' { |test~|
  fn expect-in-output { |describe-result snippets|
    var stats = (stats:from-describe-result $describe-result)

    var output = (cli:display $describe-result $stats | slurp)

    all $snippets | each { |snippet|
      str:contains $output $snippet |
        assertions:should-be $true
    }
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

    expect-in-output $describe-result [
      (styled Alpha green bold | to-string (all))' '✅"\n"
      'Total tests: 1.'
      'Passed: 1.'
      'Failed: 0.'
    ]
  }

  test 'With single failed test' {
    var describe-result = [
      &test-results=[
        &Beta=[
          &outcome=$outcomes:failed
          &output="Wooo!\n"
          &exception-log="DODO"
        ]
      ]
      &sub-results=[&]
    ]

    expect-in-output $describe-result [
      (styled Beta red bold | to-string (all))' '❌"\nWooo!\n\nDODO\n"
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
                  &exception-log="DODO"
                ]
              ]
              &sub-results=[&]
            ]
          ]
        ]
      ]
    ]

    expect-in-output $describe-result [
      (styled Alpha green bold | to-string (all))' '✅"\n"
      (styled Beta red bold | to-string (all))' '❌"\nWooo!\n\nDODO\n"
      'Total tests: 2.'
      'Passed: 1.'
      'Failed: 1.'
    ]
  }
}