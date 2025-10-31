use path
use str
use ./assertions
use ./outcomes
use ./section
use ./tests/script-gallery
use ./utils/raw

fn run-test-sandbox { |basename|
  var this-script-dir = (path:dir (src)[name])

  var sandbox-path = (path:join $this-script-dir sandbox.elv)

  var test-script-path = (script-gallery:get-script-path single-scripts $basename)

  elvish -norc $sandbox-path $test-script-path |
    from-json
}

raw:suite 'Running in sandbox' { |test~|
  test 'Passing test' {
    run-test-sandbox in-section-ok |
      assertions:should-be [
        &test-results=[&]
        &sub-sections=[
          &'My test'=[
            &test-results=[
              &'should work'=[
                &outcome=$outcomes:passed
                &output="Wiii!\nWiii2!\n"
                &exception-log=$nil
              ]
            ]
            &sub-sections=[&]
          ]
        ]
      ]
  }

  test 'Failing test' {
    var section = (run-test-sandbox in-section-failing)

    section:simplify $section |
      assertions:should-be [
        &test-results=[&]
        &sub-sections=[
          &'My test'=[
            &test-results=[
              &'should fail'=[
                &outcome=$outcomes:failed
                &output="Wooo!\nWooo2!\n"
              ]
            ]
            &sub-sections=[&]
          ]
        ]
      ]

    var exception-log = $section[sub-sections]['My test'][test-results]['should fail'][exception-log]

    str:contains $exception-log DODO |
      assertions:should-be $true
  }
}