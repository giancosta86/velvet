use str
use ./assertions
use ./outcomes
use ./section
use ./utils/raw
use ./test-result

raw:suite 'Section detection' { |test~|
  test 'Applied to test result' {
    section:is [
      &output=""
      &exception-log=$nil
    ] |
      assertions:should-be $false
  }

  test 'Applied to section' {
    section:is [
      &test-results=[&]
      &sub-sections=[&]
    ] |
      assertions:should-be $true
  }
}

raw:suite 'Section - Recursive test result mapping' { |test~|
  fn add-asterisk-to-output { |test-title test|
    put [$test-title (assoc $test output $test[output]'*')]
  }

  test 'With empty section' {
    var empty-section = [
      &test-results=[&]
      &sub-sections=[&]
    ]

    section:recursive-map-test-results $empty-section $add-asterisk-to-output~ |
      assertions:should-be $empty-section
  }

  test 'With single root test' {
    var initial-section = [
      &test-results=[
        &alpha=[
          &output='Cip'
          &exception-log=$nil
        ]
      ]
      &sub-sections=[&]
    ]

    var expected-section = [
      &test-results=[
        &alpha=[
          &output='Cip*'
          &exception-log=$nil
        ]
      ]
      &sub-sections=[&]
    ]

    section:recursive-map-test-results $initial-section $add-asterisk-to-output~ |
      assertions:should-be $expected-section
  }

  test 'With two root tests' {
    var initial-section = [
      &test-results=[
        &alpha=[
          &output='Cip'
          &exception-log=$nil
        ]
        &beta=[
          &output='Ciop'
          &exception-log=$nil
        ]
      ]

      &sub-sections=[&]
    ]

    var expected-section = [
      &test-results=[
        &alpha=[
          &output='Cip*'
          &exception-log=$nil
        ]
        &beta=[
          &output='Ciop*'
          &exception-log=$nil
        ]
      ]

      &sub-sections=[&]
    ]

    section:recursive-map-test-results $initial-section $add-asterisk-to-output~ |
      assertions:should-be $expected-section
  }

  test 'With single test in sub-section' {
    var initial-section = [
      &test-results=[&]
      &sub-sections=[
        &alpha=[
          &test-results=[
            &beta=[
              &output='Yogi'
              &exception-log=$nil
            ]
          ]
          &sub-sections=[&]
        ]
      ]
    ]

    var expected-section = [
      &test-results=[&]
      &sub-sections=[
        &alpha=[
          &test-results=[
            &beta=[
              &output='Yogi*'
              &exception-log=$nil
            ]
          ]
          &sub-sections=[&]
        ]
      ]
    ]

    section:recursive-map-test-results $initial-section $add-asterisk-to-output~ |
      assertions:should-be $expected-section
  }

  test 'With tests at different levels' {
    var initial-section = [
      &test-results=[
        &alpha=[
          &output='Alpha'
          &exception-log=$nil
        ]
        &beta=[
          &output='Beta'
          &exception-log=$nil
        ]
      ]
      &sub-sections=[
        &gamma=[
          &test-results=[
            &delta=[
              &output='Delta'
              &exception-log=$nil
            ]
          ]
          &sub-sections=[
            &epsilon=[
              &test-results=[
                &zeta=[
                  &output='Zeta'
                  &exception-log=$nil
                ]
              ]
              &sub-sections=[&]
            ]
          ]
        ]
      ]
    ]

    var expected-section = [
      &test-results=[
        &alpha=[
          &output='Alpha*'
          &exception-log=$nil
        ]
        &beta=[
          &output='Beta*'
          &exception-log=$nil
        ]
      ]
      &sub-sections=[
        &gamma=[
          &test-results=[
            &delta=[
              &output='Delta*'
              &exception-log=$nil
            ]
          ]
          &sub-sections=[
            &epsilon=[
              &test-results=[
                &zeta=[
                  &output='Zeta*'
                  &exception-log=$nil
                ]
              ]
              &sub-sections=[&]
            ]
          ]
        ]
      ]
    ]

    section:recursive-map-test-results $initial-section $add-asterisk-to-output~ |
      assertions:should-be $expected-section
  }
}

raw:suite 'Section simplification' { |test~|
  test 'On empty section' {
    var source = [
      &test-results=[&]
      &sub-sections=[&]
    ]

    section:simplify $source |
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
      &sub-sections=[&]
    ]

    section:simplify $source |
      assertions:should-be [
        &test-results=[
          &Yogi=[
            &output=Wiii!
            &outcome=$outcomes:passed
          ]
        ]
        &sub-sections=[&]
      ]
  }

  test 'With test in sub-section' {
    var source = [
      &test-results=[
        &Yogi=[
          &output="Wiii!"
          &outcome=$outcomes:passed
          &exception-log=$nil
        ]
      ]
      &sub-sections=[
        &Cip=[
          &test-results=[
            &Bubu=[
              &output="Wooo!"
              &outcome=$outcomes:failed
              &exception-log=(show ?(fail DODO) | slurp)
            ]
          ]
          &sub-sections=[&]
        ]
      ]
    ]

    section:simplify $source |
      assertions:should-be [
        &test-results=[
          &Yogi=[
            &output="Wiii!"
            &outcome=$outcomes:passed
          ]
        ]

        &sub-sections=[
          &Cip=[
            &test-results=[
              &Bubu=[
                &output="Wooo!"
                &outcome=$outcomes:failed
              ]
            ]
            &sub-sections=[&]
          ]
        ]
      ]
  }
}

raw:suite 'Section merging' { |test~|
  var empty-result = [
    &test-results=[&]
    &sub-sections=[&]
  ]

  var alpha-test = [
    &output="Alpha!"
    &outcome=$outcomes:passed
  ]

  var alpha-result = [
    &test-results=[
      &alpha=$alpha-test
    ]
    &sub-sections=[&]
  ]

  var beta-test = [
    &output="Beta!"
    &outcome=$outcomes:failed
  ]

  var beta-result = [
    &test-results=[
      &beta=$beta-test
    ]
    &sub-sections=[&]
  ]

  var gamma-test = [
    &output="Gamma!"
    &outcome=$outcomes:passed
  ]

  var gamma-result = [
    &test-results=[
      &gamma=$gamma-test
    ]
    &sub-sections=[&]
  ]

  test 'With 0 operands' {
    section:merge |
      assertions:should-be $empty-result
  }

  test 'With 1 operand' {
    put $alpha-result |
      section:merge |
      assertions:should-be $alpha-result
  }

  test 'With 2 operands' {
    put $alpha-result $beta-result |
      section:merge |
      assertions:should-be [
        &test-results=[
          &alpha=$alpha-test
          &beta=$beta-test
        ]
        &sub-sections=[&]
      ]
  }

  test 'With 3 operands' {
    put $alpha-result $beta-result $gamma-result |
      section:merge |
      assertions:should-be [
        &test-results=[
          &alpha=$alpha-test
          &beta=$beta-test
          &gamma=$gamma-test
        ]
        &sub-sections=[&]
      ]
  }
}

raw:suite 'Section merging of two operands' { |test~|
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
      &sub-sections=[&]
    ]

    var right = [
      &test-results=[&]
      &sub-sections=[&]
    ]

    put $left $right |
      section:merge |
      assertions:should-be [
        &test-results=[&]
        &sub-sections=[&]
      ]
  }

  test 'When only left is non-empty' {
    var left = [
      &test-results=[
        &Alpha=$passed-test
      ]
      &sub-sections=[&]
    ]

    var right = [
      &test-results=[&]
      &sub-sections=[&]
    ]

    put $left $right |
      section:merge |
      assertions:should-be [
        &test-results=[
          &Alpha=$passed-test
        ]
        &sub-sections=[&]
      ]
  }

  test 'When only right is non-empty' {
    var left = [
      &test-results=[&]
      &sub-sections=[&]
    ]

    var right = [
      &test-results=[
        &Beta=$failed-test
      ]
      &sub-sections=[&]
    ]

    put $left $right |
      section:merge |
      assertions:should-be [
        &test-results=[
          &Beta=$failed-test
        ]
        &sub-sections=[&]
      ]
  }

  test 'When both left and right have just a test each' {
    var left = [
      &test-results=[
        &Alpha=$passed-test
      ]
      &sub-sections=[&]
    ]

    var right = [
      &test-results=[
        &Beta=$failed-test
      ]
      &sub-sections=[&]
    ]

    put $left $right |
      section:merge |
      assertions:should-be [
        &test-results=[
          &Alpha=$passed-test
          &Beta=$failed-test
        ]
        &sub-sections=[&]
      ]
  }

  test 'When two passing tests at the same level have the same name' {
    var left = [
      &test-results=[
        &Alpha=$passed-test
      ]
      &sub-sections=[&]
    ]

    var right = [
      &test-results=[
        &Alpha=$passed-test
      ]
      &sub-sections=[&]
    ]

    put $left $right |
      section:merge |
      section:simplify (all) |
      assertions:should-be [
        &test-results=[
          &Alpha=(
            test-result:create-for-duplicated |
              test-result:simplify (all)
          )
        ]
        &sub-sections=[&]
      ]
  }

  test 'When two passing tests at the same level have the same name and different outcomes' {
    var left = [
      &test-results=[
        &Alpha=$passed-test
      ]
      &sub-sections=[&]
    ]

    var right = [
      &test-results=[
        &Alpha=$failed-test
      ]
      &sub-sections=[&]
    ]

    put $left $right |
      section:merge |
      section:simplify (all) |
      assertions:should-be [
        &test-results=[
          &Alpha=(
            test-result:create-for-duplicated |
              test-result:simplify (all)
          )
        ]
        &sub-sections=[&]
      ]
  }

  test 'When there are multiple levels of tests' {
    var left = [
      &test-results=[
        &Alpha=$passed-test
      ]
      &sub-sections=[
        &'First level'=[
          &test-results=[
            &Gamma=$passed-test
          ]
          &sub-sections=[
            &'Second level'=[
              &test-results=[
                &Delta=$passed-test
                &Epsilon=$passed-test
              ]
              &sub-sections=[&]
            ]
          ]
        ]
      ]
    ]

    var right = [
      &test-results=[
        &Sigma=$passed-test
      ]
      &sub-sections=[
        &'First level'=[
          &test-results=[&]
          &sub-sections=[
            &'Second level'=[
              &test-results=[
                &Delta=$passed-test
                &Sigma=$passed-test
                &Tau=$failed-test
              ]
              &sub-sections=[&]
            ]
          ]
        ]
      ]
    ]

    var merge-result = (
      put $left $right |
        section:merge
    )

    put $merge-result |
      section:simplify (all) |
      assertions:should-be [
        &test-results=[
          &Alpha=$passed-test
          &Sigma=$passed-test
        ]
        &sub-sections=[
          &'First level'=[
            &test-results=[
              &Gamma=$passed-test
            ]
            &sub-sections=[
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
                &sub-sections=[&]
              ]
            ]
          ]
        ]
      ]

    var delta = $merge-result[sub-sections]['First level'][sub-sections]['Second level'][test-results][Delta]

    str:contains $delta[exception-log] 'DUPLICATED TEST!' |
      assertions:should-be $true
  }
}