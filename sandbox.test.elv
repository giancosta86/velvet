use path
use str
use ./outcomes
use ./sandbox-result
use ./section
use ./test-result
use ./tests/script-gallery

var sandbox-path = (
  path:dir (src)[name] |
    path:join (all) sandbox.elv
)

fn run-single-sandbox { |basename|
  var test-script-path = (
    script-gallery:get-script-path single-scripts $basename
  )

  elvish -norc $sandbox-path $test-script-path |
    from-json
}

>> 'Running in sandbox' {
  >> 'passing test' {
    run-single-sandbox in-section-ok |
      should-be (
        section:create [&] [
          &'My test'=(
            section:create [
              &'should work'=(
                test-result:success [Wiii! Wiii2!]
              )
            ]
          )
        ] |
          sandbox-result:from-section
      )
  }

  >> 'failing test' {
    var sandbox-result = (run-single-sandbox in-section-failing)

    put $sandbox-result[section] |
      section:simplify |
      should-be (
        section:create [&] [
          &'My test'=(
            section:create [
              &'should fail'=(
                test-result:failure [Wooo! Wooo2!] []
              )
            ]
          )
        ]
      )

    all $sandbox-result[section][sub-sections]['My test'][test-results]['should fail'][exception-lines] |
      str:join "\n" |
      should-contain DODO

    put $sandbox-result[exception-lines-by-script] |
      should-be [&]
  }

  >> 'crashing script' {
    var crashing-script-path = (
      script-gallery:get-script-path single-scripts root-test-without-title
    )

    var sandbox-result = (
      elvish -norc $sandbox-path $crashing-script-path |
        from-json
    )

    put $sandbox-result[section] |
      should-be $section:empty

    var exception-log = (
      all $sandbox-result[exception-lines-by-script][$crashing-script-path] |
        str:join "\n"
    )

    >> 'exception log' {
      >> 'should contain the exception message' {
        put $exception-log |
          should-contain 'The title must be a string!'
      }

      >> 'should not reference the test-script machinery' {
        put $exception-log |
          should-not-contain "test-script.elv"
      }

      >> 'should not reference the sandbox machinery' {
        put $exception-log |
          should-not-contain "sandbox.elv"
      }
    }
  }
}