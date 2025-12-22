use ./outcomes
use ./sandbox-result

var left-result = [
  &section=[
    &test-results=[
      &test-from-left=[
        &output="Left test"
        &outcome=$outcomes:passed
        &exception-log=$nil
      ]
    ]
    &sub-sections=[&]
  ]
  &crashed-scripts=[
    &cip/ciop.test.elv=[
      alpha
      beta
      gamma
    ]
  ]
]

var right-result = [
  &section=[
    &test-results=[
      &test-from-right=[
        &output="Right test"
        &outcome=$outcomes:failed
        &exception-log=$nil
      ]
    ]
    &sub-sections=[&]
  ]
  &crashed-scripts=[
    &yogi/bubu.test.elv=[
      ro
      sigma
    ]
    &park/ranger.test.elv=[
      line-1
      line-2
      line-3
      line-4
    ]
  ]
]

>> 'Sandbox result' {
  >> 'merging' {
    >> 'with no operands' {
      all [] |
        sandbox-result:merge |
          should-be $sandbox-result:empty
    }

    >> 'with 1 operand' {
      sandbox-result:merge $left-result |
        should-be $left-result
    }

    >> 'with 2 operands' {
      >> 'when both operands are empty' {
        sandbox-result:merge $sandbox-result:empty $sandbox-result:empty |
          should-be $sandbox-result:empty
      }

      >> 'when only the left operand is non-empty' {
        sandbox-result:merge $left-result $sandbox-result:empty |
          should-be $left-result
      }

      >> 'when only the right operand is non-empty' {
        sandbox-result:merge $sandbox-result:empty $right-result |
          should-be $right-result
      }

      >> 'when both operands are non-empty' {
        sandbox-result:merge $left-result $right-result |
          should-be [
            &section=[
              &test-results=[
                &test-from-left=[
                  &output="Left test"
                  &outcome=$outcomes:passed
                  &exception-log=$nil
                ]
                &test-from-right=[
                  &output="Right test"
                  &outcome=$outcomes:failed
                  &exception-log=$nil
                ]
              ]
              &sub-sections=[&]
            ]
            &crashed-scripts=[
              &cip/ciop.test.elv=[
                alpha
                beta
                gamma
              ]
              &yogi/bubu.test.elv=[
                ro
                sigma
              ]
              &park/ranger.test.elv=[
                line-1
                line-2
                line-3
                line-4
              ]
            ]
          ]
      }
    }
  }
}