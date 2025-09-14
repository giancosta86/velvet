use ./assertions
use ./describe-context
use ./describe-result
use ./outcomes
use ./raw

raw:suite 'Describe result' { |test~|
  test 'Basic simplification' {
    var source = [
      &test-results=[&]
      &sub-results=[&]
    ]

    describe-result:simplify $source |
      assertions:should-be $source
  }

  test 'Simplification with just one test' {
    var source = [
      &test-results=[
        &Yogi=[
          &output="Wiii!"
          &outcome=$outcomes:passed
          &exception-log=$nil
        ]
      ]
      &sub-results=[&]
    ]

    describe-result:simplify $source |
      assertions:should-be [
        &test-results=[
          &Yogi=[
            &output="Wiii!"
            &outcome=$outcomes:passed
          ]
        ]

        &sub-results=[&]
      ]
  }

  test 'Simplification with test in sub-result' {
    var source = [
      &test-results=[
        &Yogi=[
          &output="Wiii!"
          &outcome=$outcomes:passed
          &exception-log=$nil
        ]
      ]
      &sub-results=[
        &Cip=[
          &test-results=[
            &Bubu=[
              &output="Wooo!"
              &outcome=$outcomes:failed
              &exception-log=(show ?(fail DODO) | slurp)
            ]
          ]
          &sub-results=[&]
        ]
      ]
    ]

    describe-result:simplify $source |
      assertions:should-be [
        &test-results=[
          &Yogi=[
            &output="Wiii!"
            &outcome=$outcomes:passed
          ]
        ]

        &sub-results=[
          &Cip=[
            &test-results=[
              &Bubu=[
                &output="Wooo!"
                &outcome=$outcomes:failed
              ]
            ]
            &sub-results=[&]
          ]
        ]
      ]
  }
}