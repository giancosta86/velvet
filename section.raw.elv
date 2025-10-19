use ./assertions
use ./outcomes
use ./section
use ./utils/raw
use ./test-result

raw:suite 'Section detection' { |test~|
  test 'Applied to test result' {
    section:is-section [
      &output=""
      &exception-log=$nil
    ] |
      assertions:should-be $false
  }

  test 'Applied to section' {
    section:is-section $section:empty |
      assertions:should-be $true
  }
}

raw:suite 'Section - Mapping test results within an entire tree' { |test~|
  fn add-asterisk-to-output { |test-result|
    assoc $test-result output $test-result[output]'*'
  }

  test 'With empty section' {
    section:map-test-results-in-tree $section:empty $add-asterisk-to-output~ |
      assertions:should-be $section:empty
  }

  test 'With single root test' {
    var source = [
      &test-results=[
        &alpha=[
          &output='Cip'
          &exception-log=$nil
        ]
      ]
      &sub-sections=[&]
    ]

    section:map-test-results-in-tree $source $add-asterisk-to-output~ |
      assertions:should-be [
        &test-results=[
          &alpha=[
            &output='Cip*'
            &exception-log=$nil
          ]
        ]
        &sub-sections=[&]
      ]
  }

  test 'With two root tests' {
    var source = [
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

    section:map-test-results-in-tree $source $add-asterisk-to-output~ |
      assertions:should-be [
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
  }

  test 'With single test in sub-section' {
    var source = [
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

    section:map-test-results-in-tree $source $add-asterisk-to-output~ |
      assertions:should-be [
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
  }

  test 'With tests at different levels' {
    var source = [
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

    section:map-test-results-in-tree $source $add-asterisk-to-output~ |
      assertions:should-be [
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
  }
}

raw:suite 'Section simplification' { |test~|
  test 'On empty section' {
    section:simplify $section:empty |
      assertions:should-be $section:empty
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
  var alpha-test-result = [
    &output="Alpha!"
    &outcome=$outcomes:passed
  ]

  var section-with-alpha = [
    &test-results=[
      &alpha=$alpha-test-result
    ]
    &sub-sections=[&]
  ]

  var beta-test-result = [
    &output="Beta!"
    &outcome=$outcomes:failed
  ]

  var section-with-beta = [
    &test-results=[
      &beta=$beta-test-result
    ]
    &sub-sections=[&]
  ]

  var gamma-test-result = [
    &output="Gamma!"
    &outcome=$outcomes:passed
  ]

  var section-with-gamma = [
    &test-results=[
      &gamma=$gamma-test-result
    ]
    &sub-sections=[&]
  ]

  test 'With 0 operands' {
    section:merge |
      assertions:should-be $section:empty
  }

  test 'With 1 operand' {
    put $section-with-alpha |
      section:merge |
      assertions:should-be $section-with-alpha
  }

  test 'With 2 operands' {
    put $section-with-alpha $section-with-beta |
      section:merge |
      assertions:should-be [
        &test-results=[
          &alpha=$alpha-test-result
          &beta=$beta-test-result
        ]
        &sub-sections=[&]
      ]
  }

  test 'With 3 operands' {
    put $section-with-alpha $section-with-beta $section-with-gamma |
      section:merge |
      assertions:should-be [
        &test-results=[
          &alpha=$alpha-test-result
          &beta=$beta-test-result
          &gamma=$gamma-test-result
        ]
        &sub-sections=[&]
      ]
  }
}

raw:suite 'Section merging with two operands' { |test~|
  var passed-test = [
    &output="Wiii!"
    &outcome=$outcomes:passed
  ]

  var failed-test = [
    &output="Wooo!"
    &outcome=$outcomes:failed
  ]

  test 'When both sides are empty' {
    var left = $section:empty

    var right = $section:empty

    put $left $right |
      section:merge |
      assertions:should-be $section:empty
  }

  test 'When only left is non-empty' {
    var left = [
      &test-results=[
        &Alpha=$passed-test
      ]
      &sub-sections=[&]
    ]

    var right = $section:empty

    put $left $right |
      section:merge |
      assertions:should-be $left
  }

  test 'When only right is non-empty' {
    var left = $section:empty

    var right = [
      &test-results=[
        &Beta=$failed-test
      ]
      &sub-sections=[&]
    ]

    put $left $right |
      section:merge |
      assertions:should-be $right
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
      assertions:should-be [
        &test-results=[
          &Alpha=$test-result:duplicate
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
      assertions:should-be [
        &test-results=[
          &Alpha=$test-result:duplicate
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

    put $left $right |
      section:merge |
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
                  &Delta=$test-result:duplicate
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
  }
}