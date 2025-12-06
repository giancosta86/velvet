use path
use str
use ./outcomes
use ./section
use ./tests/script-gallery

fn run-test-sandbox { |basename|
  var this-script-dir = (path:dir (src)[name])

  var sandbox-path = (path:join $this-script-dir sandbox.elv)

  var test-script-path = (script-gallery:get-script-path single-scripts $basename)

  elvish -norc $sandbox-path $test-script-path |
    from-json
}

>> 'Running in sandbox' {
  >> 'passing test' {
    run-test-sandbox in-section-ok |
      should-be [
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

  >> 'failing test' {
    var section = (run-test-sandbox in-section-failing)

    section:simplify $section |
      should-be [
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
      should-be $true
  }
}