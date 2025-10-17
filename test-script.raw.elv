use str
use ./assertions
use ./section
use ./outcomes
use ./stats
use ./test-script
use ./tests/test-scripts
use ./utils/raw

raw:suite 'Low-level test script execution' { |test~|
  fn run-test-script { |basename|
    var test-script-path = (test-scripts:get-path single-scripts $basename)

    test-script:run $test-script-path
  }

  test 'Empty' {
    run-test-script empty |
      assertions:should-be [
        &test-results=[&]
        &sub-sections=[&]
      ]
  }

  # test 'With metainfo checks' {
  #   var stats = (
  #     run-test-script metainfo |
  #       stats:from-section (all)
  #   )

  #   put $stats[passed] |
  #     assertions:should-be 4

  #   put $stats[failed] |
  #     assertions:should-be 0
  # }

  test 'With single passing test' {
    run-test-script single-ok |
      assertions:should-be [
        &test-results= [&]
        &sub-sections= [
          &'My description'=[
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

  test 'With single failing test' {
    run-test-script single-failing |
      section:simplify (all) |
      assertions:should-be [
        &test-results= [&]
        &sub-sections= [
          &'My description'=[
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

  test 'Exception log in failing test' {
    var section = (run-test-script single-failing)

    var exception-log = $section[sub-sections]['My description'][test-results]['should fail'][exception-log]

    str:contains $exception-log '[eval' |
      assertions:should-be $false

    str:contains $exception-log 'single-failing.test.elv:7:5-13:' |
      assertions:should-be $true
  }

  test 'With mixed outcomes' {
    var section = (run-test-script mixed-outcomes)

    put $section |
      section:simplify (all) |
      assertions:should-be [
        &test-results= [&]
        &sub-sections= [
          &'My description'=[
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

    var failed-result = $section[sub-sections]['My description'][sub-sections][Cip][sub-sections][Ciop][test-results]['should fail']

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

  test 'With single root test' {
    run-test-script root-test |
      assertions:should-be [
        &test-results=[
          &'should support single root test'=[
            &outcome=$outcomes:passed
            &output="Wiii!\nWiii2!\n"
            &exception-log=$nil
          ]
        ]
        &sub-sections=[&]
      ]
  }
}