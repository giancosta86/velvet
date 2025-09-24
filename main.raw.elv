use ./assertions
use ./main
use ./outcomes
use ./raw

raw:suite 'Getting test script' { |test~|
  test 'In directory with no tests' {
    tmp pwd = ./utils

    main:get-test-scripts |
      assertions:should-be []
  }

  test 'In directory with tests' {
    tmp pwd = ./tests/aggregator

    main:get-test-scripts |
      order |
      assertions:should-be [
        alpha.test.elv
        beta.test.elv
        gamma.test.elv
      ]
  }

  test 'In directory having nested tests' {
    tmp pwd = ./tests

    main:get-test-scripts |
      order |
      assertions:should-be [
        aggregator/alpha.test.elv
        aggregator/beta.test.elv
        aggregator/gamma.test.elv
        test-scripts/empty.test.elv
        test-scripts/metainfo.test.elv
        test-scripts/mixed-outcomes.test.elv
        test-scripts/single-failing.test.elv
        test-scripts/single-ok.test.elv
      ]
  }
}

#TODO! test check and execution