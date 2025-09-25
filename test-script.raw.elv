use path
use str
use ./describe-context
use ./describe-result
use ./assertions
use ./outcomes
use ./raw
use ./stats
use ./test-script

fn run-test-script { |basename|
  var this-script-dir = (path:dir (src)[name])

  var test-script-path = (path:join $this-script-dir tests test-scripts $basename'.test.elv')

  test-script:run $test-script-path
}

raw:suite 'Running test script' { |test~|
  test 'Empty' {
    run-test-script empty |
      assertions:should-be [
        &test-results=[&]
        &sub-results=[&]
      ]
  }

  test 'With metainfo checks' {
    run-test-script metainfo |
      stats:from-describe-result (all) |
      put (all)[failed] |
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
                &output="Wiii!\n"
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
                &output="Time to crash!\n"
              ]
            ]
            &sub-results=[&]
          ]
        ]
      ]
  }

  test 'With mixed outcomes' {
    run-test-script mixed-outcomes |
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
  }
}
