use ./aggregator
use ./assertions
use ./describe-result
use ./outcomes
use ./tests/test-scripts
use ./utils/raw

raw:suite 'Aggregator' { |test~|
  fn get-test-script { |basename|
    test-scripts:get-path aggregator $basename
  }

  test 'Running no scripts' {
    aggregator:run-test-scripts |
      assertions:should-be [
        &test-results=[&]
        &sub-results=[&]
      ]
  }

  test 'Running one script' {
    aggregator:run-test-scripts (get-test-script alpha) |
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
    aggregator:run-test-scripts (get-test-script alpha) (get-test-script beta) |
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
  }

  test 'Running three scripts' {
    aggregator:run-test-scripts (get-test-script alpha) (get-test-script beta) (get-test-script gamma) |
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
  }
}