use ../../outcomes
use ../../sandbox-result
use ../../section
use ./terse
use ./test-shared

var create-console-tester~ = (test-shared:create-console-tester-constructor $terse:report~)

>> 'Terse command-line reporting' {
  >> 'with empty section' {
    var output-tester = (create-console-tester $sandbox-result:empty)

    $output-tester[should-contain-all] [
      💬
      No test structure found.
    ]

    $output-tester[should-contain-none] [
      LOG
      Total
      Passed
      Failed
    ]
  }

  >> 'with single passed test' {
    var sandbox-result = [
      &section=[
        &test-results=[
          &Alpha=[
            &outcome=$outcomes:passed
            &output="Wiii!\n"
            &exception-log=$nil
          ]
        ]
        &sub-sections=[&]
      ]
      &crashed-scripts=[&]
    ]

    var output-tester = (create-console-tester $sandbox-result)

    $output-tester[should-contain-all] [
      ✅
      'Total tests: 1.'
    ]

    $output-tester[should-contain-none] [
      Alpha
      'Passed: 1.'
      'Failed: 0.'
      Wiii!
      LOG
    ]
  }

  >> 'with single failed test - having output' {
    var sandbox-result = [
      &section=[
        &test-results=[
          &Beta=[
            &outcome=$outcomes:failed
            &output="Wooo!\n"
            &exception-log=DODO
          ]
        ]
        &sub-sections=[&]
      ]
      &crashed-scripts=[&]
    ]

    var output-tester = (create-console-tester $sandbox-result)

    $output-tester[should-contain-all] [
      ❌
      Beta
      'OUTPUT LOG'
      'EXCEPTION LOG'
      Wooo!
      DODO
      'Total tests: 1.'
      'Passed: 0.'
      'Failed: 1.'
    ]
  }

  >> 'with single failed test - having no output' {
    var sandbox-result = [
      &section=[
        &test-results=[
          &Beta=[
            &outcome=$outcomes:failed
            &output=''
            &exception-log=DODO
          ]
        ]
        &sub-sections=[&]
      ]
      &crashed-scripts=[&]
    ]

    var output-tester = (create-console-tester $sandbox-result)

    $output-tester[should-contain-all] [
      ❌
      Beta
      'EXCEPTION LOG'
      DODO
      'Total tests: 1.'
      'Passed: 0.'
      'Failed: 1.'
    ]

    $output-tester[should-contain-none] [
      'OUTPUT LOG'
    ]
  }

  >> 'with multi-level describe result' {
    var section = [
      &test-results=[&]
      &sub-sections=[
        &WithPassed=[
          &test-results=[
            &Alpha=[
              &outcome=$outcomes:passed
              &output="Wiii!\n"
              &exception-log=$nil
            ]
          ]
          &sub-sections=[&]
        ]
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

    var sandbox-result = [
      &section=$section
      &crashed-scripts=[&]
    ]

    var output-tester = (create-console-tester $sandbox-result)

    $output-tester[should-contain-all] [
      SomeOther
      YetAnother
      ❌
      Beta
      'OUTPUT LOG'
      Wooo!
      'EXCEPTION LOG'
      DODO
      'Total tests: 2.'
      'Passed: 1.'
      'Failed: 1.'
    ]

    $output-tester[should-contain-none] [
      WithPassed
      ✅
      Alpha
      Wiii!
    ]
  }

  >> 'when running just crashed scripts' {
    var output-tester = (create-console-tester [
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
      ⛔⛔⛔
      'CRASHED SCRIPTS'
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