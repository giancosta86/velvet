use str
use ./assertions
use ./describe-result
use ./outcomes
use ./stats
use ./test-script
use ./tests/test-scripts
use ./utils/raw

raw:suite 'Running test script' { |test~|
  fn run-test-script { |basename|
    var test-script-path = (test-scripts:get-path single-scripts $basename)

    test-script:run $test-script-path
  }

  test 'Empty' {
    run-test-script empty |
      assertions:should-be [
        &test-results=[&]
        &sub-results=[&]
      ]
  }

  test 'With metainfo checks' {
    var stats = (
      run-test-script metainfo |
        stats:from-describe-result (all)
    )

    put $stats[passed] |
      assertions:should-be 4

    put $stats[failed] |
      assertions:should-be 0
  }

  test 'With single passing test' {
    run-test-script single-ok |
      assertions:should-be [
        &test-results= [&]
        &sub-results= [
          &'My description'=[
            &test-results=[
              &'should work'=[
                &outcome=$outcomes:passed
                &output="Wiii!\nWiii2!\n"
                &exception-log=$nil
              ]
            ]
            &sub-results=[&]
          ]
        ]
      ]
  }

  test 'With single failing test' {
    run-test-script single-failing |
      describe-result:simplify (all) |
      assertions:should-be [
        &test-results= [&]
        &sub-results= [
          &'My description'=[
            &test-results=[
              &'should fail'=[
                &outcome=$outcomes:failed
                &output="Wooo!\nWooo2!\n"
              ]
            ]
            &sub-results=[&]
          ]
        ]
      ]
  }

  test 'With mixed outcomes' {
    var describe-result = (run-test-script mixed-outcomes)

    put $describe-result |
      describe-result:simplify (all) |
      assertions:should-be [
        &test-results= [&]
        &sub-results= [
          &'My description'=[
            &test-results=[
              &'should pass'=[
                &outcome=$outcomes:passed
                &output="Wiii!\n"
              ]
            ]
            &sub-results=[
              &Cip=[
                &test-results=[&]
                &sub-results=[
                  &Ciop=[
                    &test-results=[
                      &'should fail'=[
                        &outcome=$outcomes:failed
                        &output="Wooo!\n"
                      ]
                    ]
                    &sub-results=[&]
                  ]
                ]
              ]
            ]
          ]
        ]
      ]

    var failed-result = $describe-result[sub-results]['My description'][sub-results][Cip][sub-results][Ciop][test-results]['should fail']

    str:contains $failed-result[exception-log] DODUS |
      assertions:should-be $true
  }

  test 'With return keyword' {
    run-test-script returning |
      assertions:should-be [
        &test-results=[&]
        &sub-results=[
          &'Returning from a test'=[
            &test-results=[
              &'should work'=[
                &outcome=$outcomes:passed
                &output="Alpha\nBeta\n"
                &exception-log=$nil
              ]
            ]
            &sub-results=[&]
          ]
        ]
      ]
  }

  test 'With root "it" block' {
    run-test-script root-it |
      assertions:should-be [
        &test-results=[
          &'should support "it" in the root'=[
            &outcome=$outcomes:passed
            &output="Wiii!\nWiii2!\n"
            &exception-log=$nil
          ]
        ]
        &sub-results=[&]
      ]
  }
}