use path
use str
use ./assertions
use ./describe-result
use ./outcomes
use ./tests/test-scripts
use ./utils/raw

fn run-test-sandbox { |basename|
  var this-script-dir = (path:dir (src)[name])

  var sandbox-path = (path:join $this-script-dir sandbox.elv)

  var test-script-path = (test-scripts:get-path single-scripts $basename)

  elvish -norc $sandbox-path $test-script-path | from-json
}

raw:suite 'Running in sandbox' { |test~|
  test 'Passing test' {
    run-test-sandbox single-ok |
      assertions:should-be [
        &test-results=[&]
        &sub-results=[
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

  test 'Failing test' {
    var describe-result = (run-test-sandbox single-failing)

    put $describe-result |
      describe-result:simplify (all) |
      assertions:should-be [
        &test-results=[&]
        &sub-results=[
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

    var exception-log = $describe-result[sub-results]['My description'][test-results]['should fail'][exception-log]

    put $exception-log |
      assertions:should-not-be &strict $nil

    str:contains $exception-log DODO |
      assertions:should-be $true
  }
}