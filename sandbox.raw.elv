use path
use str
use ./assertions
use ./describe-result
use ./outcomes
use ./raw

fn run-test-sandbox { |basename|
  var this-script-dir = (path:dir (src)[name])

  var sandbox-path = (path:join $this-script-dir sandbox.elv)

  var test-script-path = (path:join $this-script-dir tests test-scripts $basename'.elv')

  elvish -norc $sandbox-path $test-script-path | from-json
}

raw:suite 'Running in sandbox' { |test~|
  test 'Passing test' {
    var sandbox-result = (run-test-sandbox single-ok)

    put $sandbox-result[describe-result] |
      assertions:should-be [
        &test-results=[&]
        &sub-results=[
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

    put $sandbox-result[stats] |
      assertions:should-be [
        &failed=0
        &passed=1
        &total=1
      ]
  }

  test 'Failing test' {
    var sandbox-result = (run-test-sandbox single-failing)

    put $sandbox-result[describe-result] |
      describe-result:simplify (all) |
      assertions:should-be [
        &test-results=[&]
        &sub-results=[
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

    var exception-log = $sandbox-result[describe-result][sub-results]['My description'][test-results]['should fail'][exception-log]

    eq $exception-log $nil |
      assertions:should-be $false

    str:contains $exception-log : |
      assertions:should-be $true

    put $sandbox-result[stats] |
      assertions:should-be [
        &failed=1
        &passed=0
        &total=1
      ]
  }
}