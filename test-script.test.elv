use str
use ./section
use ./outcomes
use ./stats
use ./test-result
use ./test-script
use ./tests/script-gallery

fn run-standalone-script { |basename|
  var test-script-path = (script-gallery:get-standalone-script $basename)

  test-script:run $test-script-path
}

>> 'Test script' {
  >> 'execution' {
    >> 'with empty script' {
      run-standalone-script empty |
        should-be $section:empty
    }

    >> 'with metainfo checks' {
      var stats = (
        run-standalone-script metainfo |
          stats:from-section
      )

      put $stats[failed] |
        should-be 0
    }

    >> 'with root passing test' {
      run-standalone-script root-ok |
        should-be (
          section:create [
            &'My passing test'=(
              test-result:success [Wiii! Wiii2!]
            )
          ]
        )
    }

    >> 'with root failing test' {
      var section = (run-standalone-script root-failing)

      >> 'should emit a section with a root failing test' {
        put $section |
          section:simplify |
          should-be (
            section:create [
              &'My failing test'=(
                test-result:failure [Wooo! Wooo2!] []
              )
            ]
          )
      }

      >> 'should contain an exception log' {
        var exception-log = (
          all $section[test-results]['My failing test'][exception-lines] |
            str:join "\n"
        )

        put $exception-log |
          should-not-contain '[eval'

        put $exception-log |
          should-contain 'root-failing.test.elv:6:3-11:'

        put $exception-log |
          should-contain DODO
      }
    }

    >> 'with root passing and failing test' {
      run-standalone-script root-mixed |
        section:simplify |
        should-be (
          section:create [
            &'My passing test'=(
              test-result:success [Wiii! Wiii2!]
            )
            &'My failing test'=(
              test-result:failure [Wooo! Wooo2!] []
            )
          ]
        )
    }

    >> 'with section having a passing test' {
      run-standalone-script in-section-ok |
        should-be (
          section:create [&] [
            &'My test'=(
              section:create [
                &'should work'=(
                  test-result:success [Wiii! Wiii2!]
                )
              ]
            )
          ]
        )
    }

    >> 'with section having a single failing test' {
      var section = (run-standalone-script in-section-failing)

      >> 'should emit a section with a sub-section containing a failing test' {
        put $section |
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
      }

      >> 'should contain an exception log' {
        var exception-log = (
          all $section[sub-sections]['My test'][test-results]['should fail'][exception-lines] |
            str:join "\n"
        )

        put $exception-log |
          should-not-contain '[eval'

        put $exception-log |
          should-contain 'in-section-failing.test.elv:7:5-13:'

        put $exception-log |
          should-contain DODO
      }
    }

    >> 'with root test not including the title' {
      fails {
        run-standalone-script root-test-without-title
      } |
        should-be 'The title must be a string!'
    }

    >> 'with section not including the title' {
      var section = (run-standalone-script sub-section-without-title)

      >> 'should interpret the Alpha frame as a test' {
        section:simplify $section |
          should-be (
            section:create [
              &Alpha=(
                test-result:failure [] []
              )
            ]
          )
      }

      >> 'should notify the lack of a title as an exception' {
        all $section[test-results][Alpha][exception-lines] |
          str:join "\n" |
          should-contain 'The title must be a string!'
      }
    }

    >> 'with section having mixed outcomes' {
      var section = (run-standalone-script in-section-mixed)

      section:simplify $section |
        should-be (
          section:create [&] [
            &'My test'=(
              section:create [
                &'should pass'=(
                  test-result:success [Wiii!]
                )
              ] [
                &Cip=(
                  section:create [&] [
                    &Ciop=(
                      section:create [
                        &'should fail'=(
                          test-result:failure [Wooo!] []
                        )
                      ]
                    )
                  ]
                )
              ]
            )
          ]
        )

      put $section[sub-sections]['My test'] |
        put (all)[sub-sections][Cip] |
        put (all)[sub-sections][Ciop] |
        put (all)[test-results]['should fail'] |
        all (all)[exception-lines] |
        str:join "\n" |
        should-contain DODUS
    }

    >> 'with return keyword' {
      run-standalone-script returning |
        should-be (
          section:create [&] [
            &'Returning from a test'=(
              section:create [
                &'should work'=(
                  test-result:success [Alpha Beta]
                )
              ]
            )
          ]
        )
    }

    >> 'with exception handling' {
      var stats = (
        run-standalone-script exceptions |
          stats:from-section
      )

      put $stats[passed] |
        should-be 1
    }

    >> 'with test drafts' {
      var section = (run-standalone-script test-drafts)

      >> 'should generate a regular section with a tree' {
        section:simplify $section |
          should-be (
            section:create [
              &Alpha=(
                test-result:failure [] []
              )
            ] [
              &'In subsection'=(
                section:create [
                  &Beta=(
                    test-result:failure [] []
                  )
                  &Gamma=(
                    test-result:failure [] []
                  )
                  &'Longer title'=(
                    test-result:failure [] []
                  )
                ]
              )
            ]
          )
      }

      >> 'should have the not-implemented tests set to fail' {
        fn should-be-set-to-fail {
          var test-result = (one)

          all $test-result[exception-lines] |
            str:join "\n" |
            should-contain 'TEST SET TO FAIL'
        }

        put $section[test-results][Alpha] |
          should-be-set-to-fail

        put $section[sub-sections]['In subsection'][test-results][Beta] |
          should-be-set-to-fail

        put $section[sub-sections]['In subsection'][test-results][Gamma] |
          should-be-set-to-fail

        put $section[sub-sections]['In subsection'][test-results]['Longer title'] |
          should-be-set-to-fail
      }
    }
  }
}
