use path
use str
use ./outcomes
use ./section
use ./tests/script-gallery

var this-script-dir = (path:dir (src)[name])
var sandbox-path = (path:join $this-script-dir sandbox.elv)

fn run-test-sandbox { |basename|
  var test-script-path = (script-gallery:get-script-path single-scripts $basename)

  elvish -norc $sandbox-path $test-script-path |
    from-json
}

>> 'Running in sandbox' {
  >> 'passing test' {
    run-test-sandbox in-section-ok |
      should-be [
        &section=[
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
        &crashed-scripts=[&]
      ]
  }

  >> 'failing test' {
    var sandbox-result = (run-test-sandbox in-section-failing)

    put $sandbox-result[crashed-scripts] |
      should-be [&]

    var section = $sandbox-result[section]

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

    put $exception-log |
      should-contain DODO
  }

  >> 'crashing script' {
    var crashing-script-path = (script-gallery:get-script-path single-scripts root-test-without-title)

    var sandbox-result = (
      elvish -norc $sandbox-path $crashing-script-path |
        from-json
    )

    put $sandbox-result[section] |
      should-be $section:empty

    var exception-lines = $sandbox-result[crashed-scripts][$crashing-script-path]

    all $exception-lines |
      str:join "\n" |
      should-not-contain "test-script.elv"
  }
}