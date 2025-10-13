use str
use ./assertions
use ./describe-result
use ./outcomes
use ./utils/raw
use ./test-result

raw:suite 'Describe result simplification' { |test~|
  test 'On empty result' {
    var source = [
      &test-results=[&]
      &sub-results=[&]
    ]

    describe-result:simplify $source |
      assertions:should-be $source
  }

  test 'With just one test' {
    var source = [
      &test-results=[
        &Yogi=[
          &output=Wiii!
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
            &output=Wiii!
            &outcome=$outcomes:passed
          ]
        ]
        &sub-results=[&]
      ]
  }

  test 'With test in sub-result' {
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
  var empty-result = [
    &test-results=[&]
    &sub-results=[&]
  ]

  var alpha-test = [
    &output="Alpha!"
    &outcome=$outcomes:passed
  ]

  var alpha-result = [
    &test-results=[
      &alpha=$alpha-test
    ]
    &sub-results=[&]
  ]

  var beta-test = [
    &output="Beta!"
    &outcome=$outcomes:failed
  ]

  var beta-result = [
    &test-results=[
      &beta=$beta-test
    ]
    &sub-results=[&]
  ]

  var gamma-test = [
    &output="Gamma!"
    &outcome=$outcomes:passed
  ]

  var gamma-result = [
    &test-results=[
      &gamma=$gamma-test
    ]
    &sub-results=[&]
  ]

  test 'With 0 operands' {
    describe-result:merge |
      assertions:should-be $empty-result
  }

  test 'With 1 operand' {
    put $alpha-result |
      describe-result:merge |
      assertions:should-be $alpha-result
  }

  test 'With 2 operands' {
    put $alpha-result $beta-result |
      describe-result:merge |
      assertions:should-be [
        &test-results=[
          &alpha=$alpha-test
          &beta=$beta-test
        ]
        &sub-results=[&]
      ]
  }

  test 'With 3 operands' {
    put $alpha-result $beta-result $gamma-result |
      describe-result:merge |
      assertions:should-be [
        &test-results=[
          &alpha=$alpha-test
          &beta=$beta-test
          &gamma=$gamma-test
        ]
        &sub-results=[&]
      ]
  }
}

raw:suite 'Describe result merging of two operands' { |test~|
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

    put $left $right |
      describe-result:merge |
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

    put $left $right |
      describe-result:merge |
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
        &Beta=$failed-test
      ]
      &sub-results=[&]
    ]

    put $left $right |
      describe-result:merge |
      assertions:should-be [
        &test-results=[
          &Beta=$failed-test
        ]
        &sub-results=[&]
      ]
  }

  test 'When both left and right have just a test each' {
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

    put $left $right |
      describe-result:merge |
      assertions:should-be [
        &test-results=[
          &Alpha=$passed-test
          &Beta=$failed-test
        ]
        &sub-results=[&]
      ]
  }

  test 'When two passing tests at the same level have the same name' {
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

    put $left $right |
      describe-result:merge |
      describe-result:simplify (all) |
      assertions:should-be [
        &test-results=[
          &Alpha=(
            test-result:create-for-duplicated |
              test-result:simplify (all)
          )
        ]
        &sub-results=[&]
      ]
  }

  test 'When two passing tests at the same level have the same name and different outcomes' {
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

    put $left $right |
      describe-result:merge |
      describe-result:simplify (all) |
      assertions:should-be [
        &test-results=[
          &Alpha=(
            test-result:create-for-duplicated |
              test-result:simplify (all)
          )
        ]
        &sub-results=[&]
      ]
  }

  test 'When there are multiple levels of tests' {
    var left = [
      &test-results=[
        &Alpha=$passed-test
      ]
      &sub-results=[
        &'First level'=[
          &test-results=[
            &Gamma=$passed-test
          ]
          &sub-results=[
            &'Second level'=[
              &test-results=[
                &Delta=$passed-test
                &Epsilon=$passed-test
              ]
              &sub-results=[&]
            ]
          ]
        ]
      ]
    ]

    var right = [
      &test-results=[
        &Sigma=$passed-test
      ]
      &sub-results=[
        &'First level'=[
          &test-results=[&]
          &sub-results=[
            &'Second level'=[
              &test-results=[
                &Delta=$passed-test
                &Sigma=$passed-test
                &Tau=$failed-test
              ]
              &sub-results=[&]
            ]
          ]
        ]
      ]
    ]

    var merge-result = (
      put $left $right |
        describe-result:merge
    )

    put $merge-result |
      describe-result:simplify (all) |
      assertions:should-be [
        &test-results=[
          &Alpha=$passed-test
          &Sigma=$passed-test
        ]
        &sub-results=[
          &'First level'=[
            &test-results=[
              &Gamma=$passed-test
            ]
            &sub-results=[
              &'Second level'=[
                &test-results=[
                  &Delta=[
                    &outcome=$outcomes:failed
                    &output=''
                  ]
                  &Epsilon=$passed-test
                  &Sigma=$passed-test
                  &Tau=$failed-test
                ]
                &sub-results=[&]
              ]
            ]
          ]
        ]
      ]

    var delta = $merge-result[sub-results]['First level'][sub-results]['Second level'][test-results][Delta]

    str:contains $delta[exception-log] 'DUPLICATED TEST!' |
      assertions:should-be $true
  }
}