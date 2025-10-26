use ./assertions
use ./outcomes
use ./utils/raw
use ./summary
use ./test-result

raw:suite 'Summary creation' { |test~|
  test 'From section' {
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

    summary:from-section $section |
      assertions:should-be [
        &section=$section
        &stats=[
          &total=5
          &passed=3
          &failed=2
        ]
      ]
  }
}

raw:suite 'Summary simplification' { |test~|
  test 'With section tree' {
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

    summary:from-section $section |
      summary:simplify (all) |
      assertions:should-be [
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
      ]
  }
}