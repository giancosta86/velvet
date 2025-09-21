use ./assertions
use ./outcomes
use ./raw
use ./stats

raw:suite 'Stats' { |test~|
  test 'From empty describe result' {
    stats:from-describe-result [
      &test-results=[&]
      &sub-results=[&]
    ] |
      assertions:should-be [
        &total=0
        &passed=0
        &failed=0
      ]
  }

  test 'From single passed test' {
    stats:from-describe-result [
      &test-results=[
        &Cip=[
          &output="Wiii!"
          &outcome=$outcomes:passed
        ]
      ]
      &sub-results=[&]
    ] |
      assertions:should-be [
        &total=1
        &passed=1
        &failed=0
      ]
  }

  test 'From single failed test' {
    stats:from-describe-result [
      &test-results=[
        &Ciop=[
          &output="Wooo!"
          &outcome=$outcomes:failed
        ]
      ]
      &sub-results=[&]
    ] |
      assertions:should-be [
        &total=1
        &passed=0
        &failed=1
      ]
  }

  test 'From both passed and failed test' {
    stats:from-describe-result [
      &test-results=[
        &Cip=[
          &output="Wiii!"
          &outcome=$outcomes:passed
        ]
        &Ciop=[
          &output="Wooo!"
          &outcome=$outcomes:failed
        ]
      ]
      &sub-results=[&]
    ] |
      assertions:should-be [
        &total=2
        &passed=1
        &failed=1
      ]
  }

  test 'From multi-level tests' {
    stats:from-describe-result [
      &test-results=[
        &Cip=[
          &output="Wiii!"
          &outcome=$outcomes:passed
        ]
        &Ciop=[
          &output="Wooo!"
          &outcome=$outcomes:failed
        ]
      ]
      &sub-results=[
        &Alpha=[
          &test-results=[
            &Yogi=[
              &output="YogiWiii!"
              &outcome=$outcomes:passed
            ]
          ]
          &sub-results=[
            &Gamma=[
              &test-results=[
                &Ranger=[
                  &output="RangerWiii!"
                  &outcome=$outcomes:passed
                ]
              ]
              &sub-results=[&]
            ]
          ]
        ]
        &Beta=[
          &test-results=[
            &Bubu=[
              &output="BubuWooo!"
              &outcome=$outcomes:failed
            ]
          ]
          &sub-results=[&]
        ]
      ]
    ] |
      assertions:should-be [
        &total=5
        &passed=3
        &failed=2
      ]
  }
}