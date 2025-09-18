use ./assertions
use ./describe-context
use ./describe-result
use ./outcomes
use ./raw
use ./test-result

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

raw:suite 'Describe result merging' { |test~|
  var passed-test = [
    &output="Wiii!"
    &outcome=$outcomes:passed
  ]

  var failed-test = [
    &output="Wooo!"
    &outcome=$outcomes:failed
  ]

  test 'When both sides are empty' {
    var left = [
      &test-results=[&]
      &sub-results=[&]
    ]

    var right = [
      &test-results=[&]
      &sub-results=[&]
    ]

    describe-result:merge $left $right |
      assertions:should-be [
        &test-results=[&]
        &sub-results=[&]
      ]
  }

  test 'When only left is non-empty' {
    var left = [
      &test-results=[
        &Alpha=$passed-test
      ]
      &sub-results=[&]
    ]

    var right = [
      &test-results=[&]
      &sub-results=[&]
    ]

    describe-result:merge $left $right |
      assertions:should-be [
        &test-results=[
          &Alpha=$passed-test
        ]
        &sub-results=[&]
      ]
  }

  test 'When only right is non-empty' {
    var left = [
      &test-results=[&]
      &sub-results=[&]
    ]

    var right = [
      &test-results=[
        &Alpha=$passed-test
      ]
      &sub-results=[&]
    ]

    describe-result:merge $left $right |
      assertions:should-be [
        &test-results=[
          &Alpha=$passed-test
        ]
        &sub-results=[&]
      ]
  }

  test 'When both left and right have just a test' {
    var left = [
      &test-results=[
        &Alpha=$passed-test
      ]
      &sub-results=[&]
    ]

    var right = [
      &test-results=[
        &Beta=$failed-test
      ]
      &sub-results=[&]
    ]

    describe-result:merge $left $right |
      assertions:should-be [
        &test-results=[
          &Alpha=$passed-test
          &Beta=$failed-test
        ]
        &sub-results=[&]
      ]
  }

  test 'When a test name is duplicated with the same outcome' {
    var left = [
      &test-results=[
        &Alpha=$passed-test
      ]
      &sub-results=[&]
    ]

    var right = [
      &test-results=[
        &Alpha=$passed-test
      ]
      &sub-results=[&]
    ]

    describe-result:merge $left $right |
      describe-result:simplify (all) |
      assertions:should-be [
        &test-results=[
          &Alpha=(test-result:create-for-duplicated | test-result:simplify (all))
        ]
        &sub-results=[&]
      ]
  }

  test 'When a test name is duplicated with different outcomes' {
    var left = [
      &test-results=[
        &Alpha=$passed-test
      ]
      &sub-results=[&]
    ]

    var right = [
      &test-results=[
        &Alpha=$failed-test
      ]
      &sub-results=[&]
    ]

    describe-result:merge $left $right |
      describe-result:simplify (all) |
      assertions:should-be [
        &test-results=[
          &Alpha=(test-result:create-for-duplicated | test-result:simplify (all))
        ]
        &sub-results=[&]
      ]
  }
}