use ./assertions
use ./outcomes
use ./utils/raw
use ./stats

raw:suite 'Stats' { |test~|
  var passed-test = [
    &output="Wiii!"
    &outcome=$outcomes:passed
  ]

  var failed-test = [
    &output="Wooo!"
    &outcome=$outcomes:failed
  ]

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
        &Cip=$passed-test
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
        &Ciop=$failed-test
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
        &Cip=$passed-test
        &Ciop=$failed-test
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
        &Cip=$passed-test
        &Ciop=$failed-test
      ]
      &sub-results=[
        &Alpha=[
          &test-results=[
            &Yogi=$passed-test
          ]
          &sub-results=[
            &Gamma=[
              &test-results=[
                &Ranger=$passed-test
              ]
              &sub-results=[&]
            ]
          ]
        ]
        &Beta=[
          &test-results=[
            &Bubu=$failed-test
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