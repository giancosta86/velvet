use ../../outcomes
use ../../summary

var alpha = (summary:from-section [
  &test-results= [&]
  &sub-sections=[
    &'In alpha'=[
      &test-results=[
        &'should work'=[
          &outcome=$outcomes:passed
          &output="Alpha 1\n"
          &exception-log=$nil
        ]
      ]
      &sub-sections=[&]
    ]
  ]
])

var alpha-beta = (summary:from-section [
  &test-results=[&]
  &sub-sections=[
    &'In alpha'=[
      &test-results=[
        &'should work'=[
          &outcome=$outcomes:passed
          &output="Alpha 1\n"
          &exception-log=$nil
        ]
      ]
      &sub-sections=[
        &'In sub-level'=[
          &test-results=[&]
          &sub-sections=[
            &'In sub-sub-level'=[
              &test-results=[
                &'should be ok'=[
                  &outcome=$outcomes:passed
                  &output="Alpha X\n"
                  &exception-log=$nil
                ]
              ]
              &sub-sections=[&]
            ]
          ]
        ]
      ]
    ]
    &'In beta'=[
      &sub-sections=[&]
      &test-results=[
        &'has duplicate in third source file'=[
          &output="Beta 2\n"
          &outcome=$outcomes:passed
          &exception-log=$nil
        ]
      ]
    ]
  ]
])

var alpha-beta-gamma-simplified = (summary:from-section [
  &test-results=[&]
  &sub-sections=[
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
      &sub-sections=[
        &'In sub-level'=[
          &test-results=[
            &'should fail'=[
              &outcome=$outcomes:failed
              &output="Cip\nCiop\n"
            ]
          ]
          &sub-sections=[
            &'In sub-sub-level'=[
              &test-results=[
                &'should be ok'=[
                  &outcome=$outcomes:passed
                  &output="Alpha X\n"
                ]
              ]
              &sub-sections=[&]
            ]
          ]
        ]
      ]
    ]
    &'In beta'=  [
      &test-results=[
        &'has duplicate in third source file'=[
          &outcome=$outcomes:failed
          &output=""
        ]
      ]
      &sub-sections=[&]
    ]
    &'In gamma'=[
      &test-results=[
        &'should pass'=[
          &outcome=$outcomes:passed
          &output="Gamma 3\n"
        ]
      ]
      &sub-sections=[&]
    ]
  ]
])