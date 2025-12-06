use ./outcomes
use ./section
use ./stats

>> 'Stats' {
  var passed-test = [
    &output="Wiii!"
    &outcome=$outcomes:passed
  ]

  var failed-test = [
    &output="Wooo!"
    &outcome=$outcomes:failed
  ]

  >> 'from empty section' {
    stats:from-section $section:empty |
      should-be [
        &total=0
        &passed=0
        &failed=0
      ]
  }

  >> 'from single passed test' {
    stats:from-section [
      &test-results=[
        &Cip=$passed-test
      ]
      &sub-sections=[&]
    ] |
      should-be [
        &total=1
        &passed=1
        &failed=0
      ]
  }

  >> 'from single failed test' {
    stats:from-section [
      &test-results=[
        &Ciop=$failed-test
      ]
      &sub-sections=[&]
    ] |
      should-be [
        &total=1
        &passed=0
        &failed=1
      ]
  }

  >> 'from both passed and failed test' {
    stats:from-section [
      &test-results=[
        &Cip=$passed-test
        &Ciop=$failed-test
      ]
      &sub-sections=[&]
    ] |
      should-be [
        &total=2
        &passed=1
        &failed=1
      ]
  }

  >> 'from multi-level tests' {
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
      should-be [
        &total=5
        &passed=3
        &failed=2
      ]
  }
}