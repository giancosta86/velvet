use path
use ./assertions
use ./describe-result
use ./main
use ./outcomes
use ./tests/test-scripts
use ./utils/raw

raw:suite 'Getting test script' { |test~|
  test 'In directory with no tests' {
    tmp pwd = (path:join . utils)

    main:get-test-scripts |
      put [(all)] |
      assertions:should-be []
  }

  test 'In directory with tests' {
    tmp pwd = (path:join . tests aggregator)

    main:get-test-scripts |
      put [(all)] |
      order |
      assertions:should-be [
        alpha.test.elv
        beta.test.elv
        gamma.test.elv
      ]
  }

  test 'In directory having nested tests' {
    tmp pwd = (path:join . tests)

    main:get-test-scripts |
      put [(all)] |
      order |
      assertions:should-be [
        aggregator/alpha.test.elv
        aggregator/beta.test.elv
        aggregator/gamma.test.elv
        test-scripts/empty.test.elv
        test-scripts/metainfo.test.elv
        test-scripts/mixed-outcomes.test.elv
        test-scripts/returning.test.elv
        test-scripts/single-failing.test.elv
        test-scripts/single-ok.test.elv
      ]
  }
}

raw:suite 'Verifying test scripts' { |test~|
  test 'In directory with no tests' {
    tmp pwd = (path:join . utils)

    main:has-test-scripts |
      assertions:should-be $false
  }

  test 'In directory with tests' {
    tmp pwd = (path:join . tests aggregator)

    main:has-test-scripts |
      assertions:should-be $true
  }

  test 'In directory having nested tests' {
    tmp pwd = (path:join . tests)

    main:has-test-scripts |
      assertions:should-be $true
  }
}


raw:suite 'Running test scripts' { |test~|
  fn get-test-script { |basename|
    test-scripts:get-path aggregator $basename
  }

  fn create-reporter-spy {
    var actual-describe-result
    var actual-stats

    var reporter = { |describe-result stats|
      set actual-describe-result = $describe-result
      set actual-stats = $stats
    }

    put [
      &reporter=$reporter
      &get-describe-result={ put $actual-describe-result }
      &get-stats={ put $actual-stats }
    ]
  }

  test 'Running no scripts' {
    var spy = (create-reporter-spy)

    main:velvet &test-scripts=[] &reporters=[$spy[reporter]]

    $spy[get-describe-result] |
      assertions:should-be [
        &test-results=[&]
        &sub-results=[&]
      ]

    $spy[get-stats] |
      assertions:should-be [
        &total=0
        &passed=0
        &failed=0
      ]
  }

  test 'Running one script' {
    var spy = (create-reporter-spy)

    main:velvet &test-scripts=[(get-test-script alpha)] &reporters=[$spy[reporter]]

    $spy[get-describe-result] |
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

    $spy[get-stats] |
      assertions:should-be [
        &total=1
        &passed=1
        &failed=0
      ]
  }

  test 'Running two scripts' {
    var spy = (create-reporter-spy)

    main:velvet &test-scripts=[(get-test-script alpha) (get-test-script beta)] &reporters=[$spy[reporter]]

    $spy[get-describe-result] |
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
              &'is duplicated in third source file'=[
                &output="Beta 2\n"
                &outcome=$outcomes:passed
                &exception-log=$nil
              ]
            ]
          ]
        ]
      ]

    $spy[get-stats] |
      assertions:should-be [
        &total=3
        &passed=3
        &failed=0
      ]
  }

  test 'Running all scripts via inference' {
    tmp pwd = ./tests/aggregator

    var spy = (create-reporter-spy)

    main:velvet &reporters=[$spy[reporter]]

    $spy[get-describe-result] |
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
                    &output="Cip\nCiop\n"
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
              &'is duplicated in third source file'=[
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

    $spy[get-stats] |
      assertions:should-be [
        &total=6
        &passed=4
        &failed=2
      ]
  }
}