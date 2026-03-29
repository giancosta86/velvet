use ./section
use ./stats
use ./test-result

>> 'Stats' {
  var passed-test = (test-result:success [Wiii])

  var failed-test = (test-result:failure [Wooo] [])

  >> 'from empty section' {
    stats:from-section $section:empty |
      should-be $stats:empty
  }

  >> 'from single passed test' {
    section:create [&alpha=$passed-test] |
      stats:from-section |
      should-be [
        &total=1
        &passed=1
        &failed=0
      ]
  }

  >> 'from single failed test' {
    section:create [&beta=$failed-test] |
      stats:from-section |
      should-be [
        &total=1
        &passed=0
        &failed=1
      ]
  }

  >> 'from both passed and failed test' {
    section:create [&alpha=$passed-test &beta=$failed-test] |
      stats:from-section |
      should-be [
        &total=2
        &passed=1
        &failed=1
      ]
  }

  >> 'from multi-level tests' {
    section:create [&alpha=$passed-test &beta=$failed-test] [&sigma=(section:create [&gamma=$passed-test])] |
      stats:from-section |
      should-be [
        &total=3
        &passed=2
        &failed=1
      ]
  }
}