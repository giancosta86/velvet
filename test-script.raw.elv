use path
use str
use github.com/giancosta86/aurora-elvish/command
use github.com/giancosta86/aurora-elvish/exception
use ./describe-context
use ./describe-result
use ./assertions
use ./outcomes
use ./raw
use ./test-script

fn run-test-script { |basename|
  var test-script-path = (path:join (path:dir (src)[name]) tests test-scripts $basename'.elv')

  test-script:run $test-script-path
}

raw:suite 'Running empty script' { |test~|
  var script-result = (run-test-script empty)

  test 'Retrieving the stats' {
    put $script-result[stats] |
      assertions:should-be [
        &total=0
        &passed=0
        &failed=0
      ]
  }

  test 'Retrieving the describe result' {
    put $script-result[describe-result] |
      assertions:should-be [
        &test-results=[&]
        &sub-results=[&]
      ]
  }
}

raw:suite 'Running script with metainfo checks' { |test~|
  var script-result = (run-test-script metainfo)

  test 'Retrieving the stats' {
    put $script-result[stats] |
      assertions:should-be [
        &total=4
        &passed=4
        &failed=0
      ]
  }
}

raw:suite 'Running script with passing test' { |test~|
  var script-result = (run-test-script single-ok)

  test 'Retrieving the stats' {
    put $script-result[stats] |
      assertions:should-be [
        &total=1
        &passed=1
        &failed=0
      ]
  }

  test 'Retrieving the describe result' {
    put $script-result[describe-result] |
      assertions:should-be [
        &test-results= [&]
        &sub-results= [
          &'My description'=[
            &test-results=[
              &'should work'=[
                &outcome=$outcomes:passed
                &output="Wiii!\n"
                &status=$ok
              ]
            ]
            &sub-results=[&]
          ]
        ]
      ]
  }
}


raw:suite 'Running script with failing test' { |test~|
  var script-result = (run-test-script single-failing)

  test 'Retrieving the stats' {
    put $script-result[stats] |
      assertions:should-be [
        &total=1
        &passed=0
        &failed=1
      ]
  }

  test 'Retrieving the describe result' {
    put $script-result[describe-result] |
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
}


raw:suite 'Running script with mixed outcomes' { |test~|
  var script-result = (run-test-script mixed-outcomes)

  test 'Retrieving the stats' {
    put $script-result[stats] |
      assertions:should-be [
        &total=2
        &passed=1
        &failed=1
      ]
  }

  test 'Retrieving the describe result' {
    put $script-result[describe-result] |
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