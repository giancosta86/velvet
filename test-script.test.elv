use str
use ./section
use ./outcomes
use ./stats
use ./test-result
use ./test-script
use ./tests/script-gallery

fn run-single-script { |basename|
  var test-script-path = (script-gallery:get-script-path single-scripts $basename)

  test-script:run $test-script-path
}

>> 'Test script execution' {
  >> 'empty' {
    run-single-script empty |
      should-be $section:empty
  }

  >> 'with metainfo checks' {
    var stats = (
      run-single-script metainfo |
        stats:from-section
    )

    put $stats[failed] |
      should-be 0
  }

  >> 'with root passing test' {
    run-single-script root-ok |
      should-be (
        section:create [
          &'My passing test'=(
            test-result:success [Wiii! Wiii2!]
          )
        ]
      )
  }

  >> 'with root failing test' {
    run-single-script root-failing |
      section:simplify |
      should-be (
        section:create [
          &'My failing test'=(
            test-result:failure [Wooo! Wooo2!] []
          )
        ]
      )
  }

  >> 'exception log for root failing test' {
    var section = (run-single-script root-failing)

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

  >> 'with root passing and failing test' {
    run-single-script root-mixed |
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
    run-single-script in-section-ok |
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
    run-single-script in-section-failing |
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

  >> 'exception log for in-section failing test' {
    var section = (run-single-script in-section-failing)

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

  >> 'root test without title' {
    fails {
      run-single-script root-test-without-title
    } |
      should-be 'The title must be a string!'
  }

  >> 'section without title' {
    var section = (run-single-script sub-section-without-title)

    section:simplify $section |
      should-be (
        section:create [
          &Alpha=(
            test-result:failure [] []
          )
        ]
      )

    all $section[test-results][Alpha][exception-lines] |
      str:join "\n" |
      should-contain 'The title must be a string!'
  }

  >> 'test drafts' {
    var section = (run-single-script test-drafts)

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

    all $section[test-results][Alpha][exception-lines] |
      str:join "\n" |
      should-contain 'TEST SET TO FAIL'
  }

  >> 'with section having mixed outcomes' {
    var section = (run-single-script in-section-mixed)

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

    put $section[sub-sections]['My test'][sub-sections][Cip][sub-sections][Ciop][test-results]['should fail'] |
      all (all)[exception-lines] |
      str:join "\n" |
      should-contain DODUS
  }

  >> 'with return keyword' {
    run-single-script returning |
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

  >> 'exception handling' {
    var stats = (
      run-single-script exceptions |
        stats:from-section
    )

    put $stats[failed] |
      should-be 0
  }
}
