use ./outcomes
use ./section
use ./test-result

var passed-test = [
  &output='This is a passed test!'
  &outcome=$outcomes:passed
]

var failed-test = [
  &output='This is a failed test!'
  &outcome=$outcomes:failed
]

>> 'Section detection' {
  >> 'applied to test result' {
    section:is-section [
      &output=""
      &exception-log=$nil
    ] |
      should-be $false
  }

  >> 'applied to section' {
    section:is-section $section:empty |
      should-be $true
  }
}

>> 'Section - Mapping test results within an entire tree' {
  fn add-asterisk-to-output { |test-result|
    assoc $test-result output $test-result[output]'*'
  }

  >> 'with empty section' {
    section:map-test-results-in-tree $section:empty $add-asterisk-to-output~ |
      should-be $section:empty
  }

  >> 'with single root test' {
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
      should-be [
        &test-results=[
          &alpha=[
            &output='Cip*'
            &exception-log=$nil
          ]
        ]
        &sub-sections=[&]
      ]
  }

  >> 'with two root tests' {
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
      should-be [
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

  >> 'with single test in sub-section' {
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
      should-be [
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

  >> 'with tests at different levels' {
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
      should-be [
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

>> 'Section simplification' {
  >> 'on empty section' {
    section:simplify $section:empty |
      should-be $section:empty
  }

  >> 'with just one test' {
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
      should-be [
        &test-results=[
          &Yogi=[
            &output=Wiii!
            &outcome=$outcomes:passed
          ]
        ]
        &sub-sections=[&]
      ]
  }

  >> 'with test in sub-section' {
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
      should-be [
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

>> 'Section merging' {
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

  >> 'with 0 operands' {
    section:merge |
      should-be $section:empty
  }

  >> 'with 1 operand' {
    put $section-with-alpha |
      section:merge |
      should-be $section-with-alpha
  }

  >> 'with 2 operands' {
    put $section-with-alpha $section-with-beta |
      section:merge |
      should-be [
        &test-results=[
          &alpha=$alpha-test-result
          &beta=$beta-test-result
        ]
        &sub-sections=[&]
      ]
  }

  >> 'with 3 operands' {
    put $section-with-alpha $section-with-beta $section-with-gamma |
      section:merge |
      should-be [
        &test-results=[
          &alpha=$alpha-test-result
          &beta=$beta-test-result
          &gamma=$gamma-test-result
        ]
        &sub-sections=[&]
      ]
  }
}

>> 'Section merging with two operands' {
  var passed-test = [
    &output="Wiii!"
    &outcome=$outcomes:passed
  ]

  var failed-test = [
    &output="Wooo!"
    &outcome=$outcomes:failed
  ]

  >> 'when both sides are empty' {
    var left = $section:empty

    var right = $section:empty

    put $left $right |
      section:merge |
      should-be $section:empty
  }

  >> 'when only left is non-empty' {
    var left = [
      &test-results=[
        &Alpha=$passed-test
      ]
      &sub-sections=[&]
    ]

    var right = $section:empty

    put $left $right |
      section:merge |
      should-be $left
  }

  >> 'when only right is non-empty' {
    var left = $section:empty

    var right = [
      &test-results=[
        &Beta=$failed-test
      ]
      &sub-sections=[&]
    ]

    put $left $right |
      section:merge |
      should-be $right
  }

  >> 'when both left and right have just a test each' {
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
      should-be [
        &test-results=[
          &Alpha=$passed-test
          &Beta=$failed-test
        ]
        &sub-sections=[&]
      ]
  }

  >> 'when two passing tests at the same level have the same name' {
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
      should-be [
        &test-results=[
          &Alpha=$test-result:duplicate
        ]
        &sub-sections=[&]
      ]
  }

  >> 'when two passing tests at the same level have the same name and different outcomes' {
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
      should-be [
        &test-results=[
          &Alpha=$test-result:duplicate
        ]
        &sub-sections=[&]
      ]
  }

  >> 'when there are multiple levels of tests' {
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
      should-be [
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

>> 'Section - Trimming empty' {
  >> 'when the section is empty' {
    section:trim-empty $section:empty |
      should-be $section:empty
  }

  >> 'when the section contains just a test' {
    var section = [
      &test-results=[
        &alpha=$passed-test
      ]
      &sub-sections=[&]
    ]

    section:trim-empty $section |
      should-be $section
  }

  >> 'when the section contains just a non-empty sub-section' {
    var section = [
      &test-results=[&]
      &sub-sections=[
        &omega=[
          &test-results=[
            &alpha=$passed-test
          ]
          &sub-sections=[&]
        ]
      ]
    ]

    section:trim-empty $section |
      should-be $section
  }

  >> 'when the section contains just an empty sub-section' {
    var section = [
      &test-results=[&]
      &sub-sections=[
        &omega=$section:empty
      ]
    ]

    section:trim-empty $section |
      should-be $section:empty
  }

  >> 'in a more complex structure' {
    var section = [
      &test-results=[&]
      &sub-sections=[
        &ro=[
          &test-results=[&]
          &sub-sections=[
            &sigma=$section:empty
            &tau=[
              &test-results=[
                &ciop=$passed-test
              ]
              &sub-sections=[&]
            ]
          ]
        ]
        &level-1=[
          &test-results=[&]
          &sub-sections=[
            &level-2=[
              &test-results=[&]
              &sub-sections=[
                &level-3=$section:empty
              ]
            ]
          ]
        ]
        &omega=[
          &test-results=[
            &alpha=$failed-test
          ]
          &sub-sections=[&]
        ]
      ]
    ]

    section:trim-empty $section |
      should-be [
        &test-results=[&]
        &sub-sections=[
          &ro=[
            &test-results=[&]
            &sub-sections=[
              &tau=[
                &test-results=[
                  &ciop=$passed-test
                ]
                &sub-sections=[&]
              ]
            ]
          ]
          &omega=[
            &test-results=[
              &alpha=$failed-test
            ]
            &sub-sections=[&]
          ]
        ]
      ]
  }
}

>> 'Section - Keeping failed test results' {
  >> 'when the section is empty' {
    section:keep-failed-test-results $section:empty |
      should-be $section:empty
  }

  >> 'when the section contains a passed test' {
    section:keep-failed-test-results [
      &test-results=[
        &alpha=$passed-test
      ]
      &sub-sections=[&]
    ] |
      should-be $section:empty
  }

  >> 'when the section contains a passing and a failing test' {
    section:keep-failed-test-results [
      &test-results=[
        &alpha=$passed-test
        &beta=$failed-test
      ]
      &sub-sections=[&]
    ] |
      should-be [
        &test-results=[
          &beta=$failed-test
        ]
        &sub-sections=[&]
      ]
  }

  >> 'when the section contains a sub-section with mixed tests' {
    section:keep-failed-test-results [
      &test-results=[&]
      &sub-sections=[
        &my-nested-section=[
          &test-results=[
            &alpha=$passed-test
            &beta=$failed-test
          ]
          &sub-sections=[&]
        ]
      ]
    ] |
      should-be [
        &test-results=[&]
        &sub-sections=[
          &my-nested-section=[
            &test-results=[
              &beta=$failed-test
            ]
            &sub-sections=[&]
          ]
        ]
      ]
  }

  >> 'with more complex source' {
    section:keep-failed-test-results [
      &test-results=[
        &some-passed=$passed-test
        &some-failed=$failed-test
      ]
      &sub-sections=[
        &with-only-passed=[
          &test-results=[
            &omicron=$passed-test
            &ro=$passed-test
            &sigma=$passed-test
          ]
          &sub-sections=[&]
        ]
        &my-nested-section=[
          &test-results=[
            &alpha=$passed-test
            &beta=$failed-test
          ]
          &sub-sections=[&]
        ]
      ]
    ] |
      should-be [
        &test-results=[
          &some-failed=$failed-test
        ]
        &sub-sections=[
          &my-nested-section=[
            &test-results=[
              &beta=$failed-test
            ]
            &sub-sections=[&]
          ]
        ]
      ]
  }
}