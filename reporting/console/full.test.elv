use ./full
use ./test-shared

>> 'Full command-line reporting' {
  test-shared:run-console-tests [
    &'>>~'=$'>>~'

    &console-reporter=$full:report~

    &scenarios= [
      &empty-section=[
        &all=[
          '💬 No test structure found.'
        ]
        &none=[
          LOG
          Total
          Passed
          Failed
        ]
      ]
      &single-passed-test=[
        &all=[
          '✅ Alpha'
          '✅ Total tests: 1.'
        ]
        &none=[
          'Passed: 1.'
          'Failed: 0.'
          Wiii!
          LOG
        ]
      ]
      &single-failed-having-output-and-exception=[
        &all=[
          '❌ Beta'
          'OUTPUT LOG'
          Wooo!
          'EXCEPTION LOG'
          DODO
          '❌ Total tests: 1.'
          'Passed: 0.'
          'Failed: 1.'
        ]
        &none=[]
      ]
      &single-failed-having-output-only=[
        &all=[
          '❌ Beta'
          'OUTPUT LOG'
          Wooo!
          '❌ Total tests: 1.'
          'Passed: 0.'
          'Failed: 1.'
        ]
        &none=[
          'EXCEPTION LOG'
        ]
      ]
      &single-failed-having-exception-only=[
        &all=[
          '❌ Beta'
          'EXCEPTION LOG'
          DODO
          '❌ Total tests: 1.'
          'Passed: 0.'
          'Failed: 1.'
        ]
        &none=[
          'OUTPUT LOG'
        ]
      ]
      &multi-level-tree=[
        &all=[
          '✅ Alpha'
          SomeOther
          YetAnother
          '❌ Beta'
          'OUTPUT LOG'
          Wooo!
          'EXCEPTION LOG'
          DODO
          '❌ Total tests: 2.'
          'Passed: 1.'
          'Failed: 1.'
        ]
        &none=[
          Wiii!
        ]
      ]
    ]
  ]
}