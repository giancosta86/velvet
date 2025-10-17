use path
use ./assertions
use ./main
use ./outcomes
use ./section
use ./tests/aggregator/sections
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

    var expected-scripts = [(
      all $test-scripts:aggregator | each { |script|
        path:base $script
      }
    )]

    main:get-test-scripts |
      order |
      put [(all)] |
      assertions:should-be $expected-scripts
  }

  test 'In directory having nested tests' {
    tmp pwd = (path:join $this-script-dir tests)

    main:get-test-scripts |
      order |
      put [(all)] |
      assertions:should-be $test-scripts:all
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
    var section
    var stats

    var reporter = { |actual-section actual-stats|
      set section = $actual-section
      set stats = $actual-stats
    }

    put [
      &reporter=$reporter
      &get-section={ put $section }
      &get-stats={ put $stats }
    ]
  }

  test 'Running no scripts' {
    var spy = (create-reporter-spy)

    main:velvet &test-scripts=[] &reporters=[$spy[reporter]]

    $spy[get-section] |
      assertions:should-be [
        &test-results=[&]
        &sub-sections=[&]
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

    $spy[get-section] |
      assertions:should-be $sections:alpha

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

    $spy[get-section] |
      assertions:should-be $sections:alpha-beta

    $spy[get-stats] |
      assertions:should-be [
        &total=3
        &passed=3
        &failed=0
      ]
  }

  test 'Return value when running two scripts' {
    var run-result = (
      main:velvet &test-scripts=[(get-test-script alpha) (get-test-script beta)] &reporters=[]
    )

    put $run-result[section] |
      assertions:should-be $sections:alpha-beta

    put $run-result[stats] |
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

    $spy[get-section] |
      section:simplify (all) |
      assertions:should-be $sections:alpha-beta-gamma

    $spy[get-stats] |
      assertions:should-be [
        &total=6
        &passed=4
        &failed=2
      ]
  }
}