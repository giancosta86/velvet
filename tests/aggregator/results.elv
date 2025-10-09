use ../../outcomes

var alpha = [
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

var alpha-beta = [
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

var alpha-beta-gamma = [
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