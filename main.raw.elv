use path
use ./assertions
use ./describe-result
use ./main
use ./outcomes
use ./tests/aggregator/results
use ./tests/test-scripts
use ./utils/raw

var this-script-dir = (path:dir (src)[name])

raw:suite 'Getting test script' { |test~|
  test 'In directory with no tests' {
    tmp pwd = (path:join $this-script-dir utils)

    main:get-test-scripts |
      put [(all)] |
      assertions:should-be []
  }

  test 'In directory with tests' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    main:get-test-scripts |
      put [(all)] |
      order |
      assertions:should-be [
        alpha.test.elv
        beta.test.elv
        gamma.test.elv
      ]
  }

  test 'In directory having nested tests' {
    tmp pwd = (path:join $this-script-dir tests)

    main:get-test-scripts |
      put [(all)] |
      order |
      assertions:should-be [
        aggregator/alpha.test.elv
        aggregator/beta.test.elv
        aggregator/gamma.test.elv
        single-scripts/empty.test.elv
        single-scripts/metainfo.test.elv
        single-scripts/mixed-outcomes.test.elv
        single-scripts/returning.test.elv
        single-scripts/root-it.test.elv
        single-scripts/single-failing.test.elv
        single-scripts/single-ok.test.elv
      ]
  }
}

raw:suite 'Searching for test scripts' { |test~|
  test 'In directory with no tests' {
    tmp pwd = (path:join $this-script-dir utils)

    main:has-test-scripts |
      assertions:should-be $false
  }

  test 'In directory with tests' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    main:has-test-scripts |
      assertions:should-be $true
  }

  test 'In directory having nested tests' {
    tmp pwd = (path:join $this-script-dir tests)

    main:has-test-scripts |
      assertions:should-be $true
  }
}

raw:suite 'Top-level test script execution' { |test~|
  fn get-test-script { |basename|
    test-scripts:get-path aggregator $basename
  }

  fn create-reporter-spy {
    var describe-result
    var stats

    var reporter = { |actual-describe-result actual-stats|
      set describe-result = $actual-describe-result
      set stats = $actual-stats
    }

    put [
      &reporter=$reporter
      &get-describe-result={ put $describe-result }
      &get-stats={ put $stats }
    ]
  }

  test 'Running no scripts' {
    var spy = (create-reporter-spy)

    main:velvet &test-scripts=[] &reporters=[$spy[reporter]]

    $spy[get-describe-result] |
      assertions:should-be [
        &test-results=[&]
        &sub-results=[&]
      ]

    $spy[get-stats] |
      assertions:should-be [
        &total=0
        &passed=0
        &failed=0
      ]
  }

  test 'Running one script' {
    var spy = (create-reporter-spy)

    main:velvet &test-scripts=[(get-test-script alpha)] &reporters=[$spy[reporter]]

    $spy[get-describe-result] |
      assertions:should-be $results:alpha

    $spy[get-stats] |
      assertions:should-be [
        &total=1
        &passed=1
        &failed=0
      ]
  }

  test 'Running two scripts' {
    var spy = (create-reporter-spy)

    main:velvet &test-scripts=[(get-test-script alpha) (get-test-script beta)] &reporters=[$spy[reporter]]

    $spy[get-describe-result] |
      assertions:should-be $results:alpha-beta

    $spy[get-stats] |
      assertions:should-be [
        &total=3
        &passed=3
        &failed=0
      ]
  }

  test 'Running all scripts via inference' {
    tmp pwd = ./tests/aggregator

    var spy = (create-reporter-spy)

    main:velvet &reporters=[$spy[reporter]]

    $spy[get-describe-result] |
      describe-result:simplify (all) |
      assertions:should-be $results:alpha-beta-gamma

    $spy[get-stats] |
      assertions:should-be [
        &total=6
        &passed=4
        &failed=2
      ]
  }
}