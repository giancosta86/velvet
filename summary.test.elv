use ./outcomes
use ./summary
use ./test-result

var crashed-scripts = [
  &park/yogi.test.elv=[
    alpha
    beta
    gamma
  ]
]

>> 'Summary creation' {
  >> 'from sandbox result' {
    var section = [
      &test-results=[
        &alpha=[
          &output=''
          &outcome=$outcomes:passed
        ]
      ]
      &sub-sections=[
        &beta=[
          &test-results=[
            &gamma=[
              &output=''
              &outcome=$outcomes:passed
            ]
            &delta=[
              &output=''
              &outcome=$outcomes:failed
            ]
          ]
          &sub-sections=[
            &epsilon=[
              &test-results=[
                &zeta=$test-result:duplicate
                &eta=[
                  &output=''
                  &outcome=$outcomes:passed
                ]
              ]
              &sub-sections=[&]
            ]
          ]
        ]
      ]
    ]

    var sandbox-result = [
      &section=$section
      &crashed-scripts=$crashed-scripts
    ]

    summary:from-sandbox-result $sandbox-result |
      should-be [
        &section=$section
        &stats=[
          &total=5
          &passed=3
          &failed=2
        ]
        &crashed-scripts=$crashed-scripts
      ]
  }
}

>> 'Summary simplification' {
  >> 'with section tree' {
    var section = [
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
          &sub-sections=[
            &Ciop=[
              &test-results=[
                &ranger=$test-result:duplicate
              ]
              &sub-sections=[&]
            ]
          ]
        ]
      ]
    ]

    var sandbox-result = [
      &section=$section
      &crashed-scripts=$crashed-scripts
    ]

    summary:from-sandbox-result $sandbox-result |
      summary:simplify (all) |
      should-be [
        &section=[
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
              &sub-sections=[
                &Ciop=[
                  &test-results=[
                    &ranger=[
                      &output=''
                      &outcome=$outcomes:failed
                    ]
                  ]
                  &sub-sections=[&]
                ]
              ]
            ]
          ]
        ]
        &stats=[
          &total=3
          &passed=1
          &failed=2
        ]
        &crashed-scripts=$crashed-scripts
      ]
  }
}