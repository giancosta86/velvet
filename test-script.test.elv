use str
use ./section
use ./outcomes
use ./stats
use ./test-script
use ./tests/script-gallery

>> 'Test script execution' {
  fn run-test-script { |basename|
    var test-script-path = (script-gallery:get-script-path single-scripts $basename)

    test-script:run $test-script-path
  }

  >> 'empty' {
    run-test-script empty |
      should-be $section:empty
  }

  >> 'with metainfo checks' {
    var stats = (
      run-test-script metainfo |
        stats:from-section (all)
    )

    put $stats[passed] |
      should-be 5

    put $stats[failed] |
      should-be 0
  }

  >> 'with root passing test' {
    run-test-script root-ok |
      should-be [
        &test-results= [
          &'My passing test'=[
            &outcome=$outcomes:passed
            &output="Wiii!\nWiii2!\n"
            &exception-log=$nil
          ]
        ]
        &sub-sections= [&]
      ]
  }

  >> 'with root failing test' {
    run-test-script root-failing |
      section:simplify (all) |
      should-be [
        &test-results= [
          &'My failing test'=[
            &outcome=$outcomes:failed
            &output="Wooo!\nWooo2!\n"
          ]
        ]
        &sub-sections= [&]
      ]
  }

  >> 'exception log for root failing test' {
    var section = (run-test-script root-failing)

    var exception-log = $section[test-results]['My failing test'][exception-log]

    str:contains $exception-log '[eval' |
      should-be $false

    str:contains $exception-log 'root-failing.test.elv:6:3-11:' |
      should-be $true

    str:contains $exception-log DODO |
      should-be $true
  }

  >> 'with root passing and failing test' {
    run-test-script root-mixed |
      section:simplify (all) |
      should-be [
        &test-results= [
          &'My passing test'=[
            &outcome=$outcomes:passed
            &output="Wiii!\nWiii2!\n"
          ]

          &'My failing test'=[
            &outcome=$outcomes:failed
            &output="Wooo!\nWooo2!\n"
          ]
        ]
        &sub-sections= [&]
      ]
  }

  >> 'with section having a passing test' {
    run-test-script in-section-ok |
      should-be [
        &test-results= [&]
        &sub-sections= [
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

  >> 'with section having a single failing test' {
    run-test-script in-section-failing |
      section:simplify (all) |
      should-be [
        &test-results= [&]
        &sub-sections= [
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
  }

  >> 'exception log for in-section failing test' {
    var section = (run-test-script in-section-failing)

    var exception-log = $section[sub-sections]['My test'][test-results]['should fail'][exception-log]

    str:contains $exception-log '[eval' |
      should-be $false

    str:contains $exception-log 'in-section-failing.test.elv:7:5-13:' |
      should-be $true

    str:contains $exception-log DODO |
      should-be $true
  }

  >> 'root test without title' {
    throws {
      run-test-script root-test-without-title
    } |
      print (all)[reason] |
      str:contains (all) 'arity mismatch' |
      should-be $true
  }

  >> 'section without title' {
    var section = (run-test-script sub-section-without-title)

    section:simplify $section |
      should-be [
        &test-results=[
          &Alpha=[
            &outcome=$outcomes:failed
            &output=''
          ]
        ]
        &sub-sections=[&]
      ]

    put $section[test-results][Alpha][exception-log] |
      str:contains (all) 'arity mismatch' |
      should-be $true
  }

  >> 'with section having mixed outcomes' {
    var section = (run-test-script in-section-mixed)

    section:simplify $section |
      should-be [
        &test-results= [&]
        &sub-sections= [
          &'My test'=[
            &test-results=[
              &'should pass'=[
                &outcome=$outcomes:passed
                &output="Wiii!\n"
              ]
            ]
            &sub-sections=[
              &Cip=[
                &test-results=[&]
                &sub-sections=[
                  &Ciop=[
                    &test-results=[
                      &'should fail'=[
                        &outcome=$outcomes:failed
                        &output="Wooo!\n"
                      ]
                    ]
                    &sub-sections=[&]
                  ]
                ]
              ]
            ]
          ]
        ]
      ]

    var failed-result = $section[sub-sections]['My test'][sub-sections][Cip][sub-sections][Ciop][test-results]['should fail']

    str:contains $failed-result[exception-log] DODUS |
      should-be $true
  }

  >> 'with return keyword' {
    run-test-script returning |
      should-be [
        &test-results=[&]
        &sub-sections=[
          &'Returning from a test'=[
            &test-results=[
              &'should work'=[
                &outcome=$outcomes:passed
                &output="Alpha\nBeta\n"
                &exception-log=$nil
              ]
            ]
            &sub-sections=[&]
          ]
        ]
      ]
  }

  >> 'exception handling' {
    var stats = (
      run-test-script exceptions |
        stats:from-section (all)
    )

    put $stats[passed] |
      should-be 1

    put $stats[failed] |
      should-be 0
  }
}