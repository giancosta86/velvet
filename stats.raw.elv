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

  test 'From empty section' {
    stats:from-section [
      &test-results=[&]
      &sub-sections=[&]
    ] |
      assertions:should-be [
        &total=0
        &passed=0
        &failed=0
      ]
  }

  test 'From single passed test' {
    stats:from-section [
      &test-results=[
        &Cip=$passed-test
      ]
      &sub-sections=[&]
    ] |
      assertions:should-be [
        &total=1
        &passed=1
        &failed=0
      ]
  }

  test 'From single failed test' {
    stats:from-section [
      &test-results=[
        &Ciop=$failed-test
      ]
      &sub-sections=[&]
    ] |
      assertions:should-be [
        &total=1
        &passed=0
        &failed=1
      ]
  }

  test 'From both passed and failed test' {
    stats:from-section [
      &test-results=[
        &Cip=$passed-test
        &Ciop=$failed-test
      ]
      &sub-sections=[&]
    ] |
      assertions:should-be [
        &total=2
        &passed=1
        &failed=1
      ]
  }

  test 'From multi-level tests' {
    stats:from-section [
      &test-results=[
        &Cip=$passed-test
        &Ciop=$failed-test
      ]
      &sub-sections=[
        &Alpha=[
          &test-results=[
            &Yogi=$passed-test
          ]
          &sub-sections=[
            &Gamma=[
              &test-results=[
                &Ranger=$passed-test
              ]
              &sub-sections=[&]
            ]
          ]
        ]
        &Beta=[
          &test-results=[
            &Bubu=$failed-test
          ]
          &sub-sections=[&]
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