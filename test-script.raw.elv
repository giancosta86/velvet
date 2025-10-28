use str
use ./assertions
use ./section
use ./outcomes
use ./stats
use ./test-script
use ./tests/script-gallery
use ./utils/exception
use ./utils/raw

raw:suite 'Test script execution' { |test~|
  fn run-test-script { |basename|
    var test-script-path = (script-gallery:get-script-path single-scripts $basename)

    test-script:run $test-script-path
  }

  test 'Empty' {
    run-test-script empty |
      assertions:should-be $section:empty
  }

  test 'With metainfo checks' {
    var stats = (
      run-test-script metainfo |
        stats:from-section (all)
    )

    put $stats[passed] |
      assertions:should-be 5

    put $stats[failed] |
      assertions:should-be 0
  }

  test 'With root passing test' {
    run-test-script root-ok |
      assertions:should-be [
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

  test 'With root failing test' {
    run-test-script root-failing |
      section:simplify (all) |
      assertions:should-be [
        &test-results= [
          &'My failing test'=[
            &outcome=$outcomes:failed
            &output="Wooo!\nWooo2!\n"
          ]
        ]
        &sub-sections= [&]
      ]
  }

  test 'Exception log for root failing test' {
    var section = (run-test-script root-failing)

    var exception-log = $section[test-results]['My failing test'][exception-log]

    str:contains $exception-log '[eval' |
      assertions:should-be $false

    str:contains $exception-log 'root-failing.test.elv:6:3-11:' |
      assertions:should-be $true

    str:contains $exception-log DODO |
      assertions:should-be $true
  }

  test 'With root passing and failing test' {
    run-test-script root-mixed |
      section:simplify (all) |
      assertions:should-be [
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

  test 'With section having a passing test' {
    run-test-script in-section-ok |
      assertions:should-be [
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

  test 'With section having a single failing test' {
    run-test-script in-section-failing |
      section:simplify (all) |
      assertions:should-be [
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

  test 'Exception log for in-section failing test' {
    var section = (run-test-script in-section-failing)

    var exception-log = $section[sub-sections]['My test'][test-results]['should fail'][exception-log]

    str:contains $exception-log '[eval' |
      assertions:should-be $false

    str:contains $exception-log 'in-section-failing.test.elv:7:5-13:' |
      assertions:should-be $true

    str:contains $exception-log DODO |
      assertions:should-be $true
  }

  test 'Root test without title' {
    exception:expect-throws {
      run-test-script root-test-without-title
    } |
      print (all)[reason] |
      str:contains (all) 'arity mismatch' |
      assertions:should-be $true
  }

  test 'Section without title' {
    var section = (run-test-script sub-section-without-title)

    section:simplify $section |
      assertions:should-be [
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
      assertions:should-be $true
  }

  test 'With section having mixed outcomes' {
    var section = (run-test-script in-section-mixed)

    section:simplify $section |
      assertions:should-be [
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
      assertions:should-be $true
  }

  test 'With return keyword' {
    run-test-script returning |
      assertions:should-be [
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

  test 'Exception handling' {
    var stats = (
      run-test-script exceptions |
        stats:from-section (all)
    )

    put $stats[passed] |
      assertions:should-be 1

    put $stats[failed] |
      assertions:should-be 0
  }
}