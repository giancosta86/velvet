use ./assertions
use ./describe-result
use ./main
use ./outcomes
use ./raw

raw:suite 'Getting test script' { |test~|
  test 'In directory with no tests' {
    tmp pwd = ./utils

    main:get-test-scripts |
      assertions:should-be []
  }

  test 'In directory with tests' {
    tmp pwd = ./tests/aggregator

    main:get-test-scripts |
      order |
      assertions:should-be [
        alpha.test.elv
        beta.test.elv
        gamma.test.elv
      ]
  }

  test 'In directory having nested tests' {
    tmp pwd = ./tests

    main:get-test-scripts |
      order |
      assertions:should-be [
        aggregator/alpha.test.elv
        aggregator/beta.test.elv
        aggregator/gamma.test.elv
        test-scripts/empty.test.elv
        test-scripts/metainfo.test.elv
        test-scripts/mixed-outcomes.test.elv
        test-scripts/single-failing.test.elv
        test-scripts/single-ok.test.elv
      ]
  }
}


raw:suite 'Checking test scripts' { |test~|
  test 'In directory with no tests' {
    tmp pwd = ./utils

    main:has-test-scripts |
      assertions:should-be $false
  }

  test 'In directory with tests' {
    tmp pwd = ./tests/aggregator

    main:has-test-scripts |
      assertions:should-be $true
  }

  test 'In directory having nested tests' {
    tmp pwd = ./tests

    main:has-test-scripts |
      assertions:should-be $true
  }
}


raw:suite 'Running test scripts' { |test~|
  fn get-test-script { |basename|
    put tests/aggregator/$basename.test.elv
  }

  test 'Running no scripts' {
    var actual-describe-result

    main:test &test-scripts=[] &reporters=[{ |describe-result| set actual-describe-result = $describe-result }]

    put $actual-describe-result |
      assertions:should-be [
        &test-results=[&]
        &sub-results=[&]
      ]
  }

  test 'Running one script' {
    var actual-describe-result

    main:test &test-scripts=[(get-test-script alpha)] &reporters=[{ |describe-result| set actual-describe-result = $describe-result }]

    put $actual-describe-result |
      assertions:should-be [
        &test-results= [&]
        &sub-results=[
          &'In alpha'=[
            &test-results=[
              &'should work'=[
                &outcome=$outcomes:passed
                &output="Alpha 1\n"
                &exception-log=$nil
              ]
            ]
            &sub-results=[&]
          ]
        ]
      ]
  }

  test 'Running two scripts' {
    var actual-describe-result

    main:test &test-scripts=[(get-test-script alpha) (get-test-script beta)] &reporters=[{ |describe-result| set actual-describe-result = $describe-result }]


    put $actual-describe-result |
      assertions:should-be [
        &test-results= [&]
        &sub-results=[
          &'In alpha'=[
            &test-results=[
              &'should work'=[
                &outcome=$outcomes:passed
                &output="Alpha 1\n"
                &exception-log=$nil
              ]
            ]
            &sub-results=[
              &'In sub-level'=[
                &test-results=[&]
                &sub-results=[
                  &'In sub-sub-level'=[
                    &test-results=[
                      &'should be ok'=[
                        &outcome=$outcomes:passed
                        &output="Alpha X\n"
                        &exception-log=$nil
                      ]
                    ]
                    &sub-results=[&]
                  ]
                ]
              ]
            ]
          ]

          &'In beta'=[
            &sub-results=[&]
            &test-results=[
              &'is duplicated'=[
                &output="Beta 2\n"
                &outcome=$outcomes:passed
                &exception-log=$nil
              ]
            ]
          ]
        ]
      ]
  }

  test 'Running all scripts via inference' {
    tmp pwd = ./tests/aggregator

    var actual-describe-result

    main:test &reporters=[{ |describe-result| set actual-describe-result = $describe-result }]

    put $actual-describe-result |
      describe-result:simplify (all) |
      assertions:should-be [
        &test-results=[&]
        &sub-results=[
          &'In alpha'=[
            &test-results=[
              &'should work'=[
                &outcome=$outcomes:passed
                &output="Alpha 1\n"
              ]
              &'should work too'=[
                &outcome=$outcomes:passed
                &output="Alpha 5\n"
              ]
            ]
            &sub-results=[
              &'In sub-level'=[
                &test-results=[
                  &'should fail'=[
                    &outcome=$outcomes:failed
                    &output=''
                  ]
                ]
                &sub-results=[
                  &'In sub-sub-level'=[
                    &test-results=[
                      &'should be ok'=[
                        &outcome=$outcomes:passed
                        &output="Alpha X\n"
                      ]
                    ]
                    &sub-results=[&]
                  ]
                ]
              ]
            ]
          ]
          &'In beta'=  [
            &test-results=[
              &'is duplicated'=[
                &outcome=$outcomes:failed
                &output=""
              ]
            ]
            &sub-results=[&]
          ]
          &'In gamma'=[
            &test-results=[
              &'should pass'=[
                &outcome=$outcomes:passed
                &output="Gamma 3\n"
              ]
            ]
            &sub-results=[&]
          ]
        ]
      ]
  }
}