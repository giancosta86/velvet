use path
use re
use str
use ./assertions
use ./main
use ./summary
use ./tests/aggregator/summaries
use ./tests/script-gallery
use ./utils/exception
use ./utils/raw
use ./utils/string

var this-script-dir = (path:dir (src)[name])

fn get-test-script { |basename|
  script-gallery:get-script-path aggregator $basename
}

fn create-reporter-spy {
  var summary

  var reporter = { |actual-summary|
    set summary = $actual-summary
  }

  put [
    &reporter=$reporter
    &get-summary={
      put $summary
    }
  ]
}

raw:suite 'Listing test scripts' { |test~|
  test 'In directory with no tests' {
    tmp pwd = (path:join $this-script-dir utils)

    main:get-test-scripts |
      put [(all)] |
      assertions:should-be []
  }

  test 'In directory with tests' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    var expected-scripts = [(
      all $script-gallery:aggregator |
        each $path:base~
    )]

    main:get-test-scripts |
      order |
      put [(all)] |
      assertions:should-be $expected-scripts
  }

  test 'In directory with nested tests' {
    tmp pwd = (path:join $this-script-dir tests)

    main:get-test-scripts |
      order |
      put [(all)] |
      assertions:should-be $script-gallery:all
  }
}

raw:suite 'Boolean detection of test scripts' { |test~|
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

raw:suite 'Top-level command' { |test~|
  test 'Running one aggregator script' {
    var spy = (create-reporter-spy)

    main:velvet &reporters=[$spy[reporter]] (get-test-script alpha)

    $spy[get-summary] |
      assertions:should-be $summaries:alpha
  }

  test 'Running two aggregator scripts' {
    var spy = (create-reporter-spy)

    main:velvet &reporters=[$spy[reporter]] (get-test-script alpha) (get-test-script beta)

    $spy[get-summary] |
      assertions:should-be $summaries:alpha-beta
  }

  test 'Running all aggregator scripts via inference' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    var spy = (create-reporter-spy)

    main:velvet &reporters=[$spy[reporter]]
    $spy[get-summary] |
      summary:simplify (all) |
      assertions:should-be $summaries:alpha-beta-gamma-simplified
  }

  test 'Running all aggregator tests and asserting success' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    exception:throws {
      main:velvet &must-pass &reporters=[]
    } |
      exception:get-fail-content |
      assertions:should-be '❌ There are failed tests!'
  }

  test 'Running all the aggregator tests and requesting a summary' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    main:velvet &put &reporters=[] |
      summary:simplify (all) |
      assertions:should-be $summaries:alpha-beta-gamma-simplified
  }

  test 'Running all the aggregator tests and checking the byte output' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    var home-directory = (put ~)

    var expected-log-path = (path:join $this-script-dir tests aggregator all.log)

    var expected-log = (slurp < $expected-log-path)

    main:velvet |
      slurp |
      string:unstyled (all) |
      str:trim-space (all) |
      re:replace '([ \t]*?)\S+?/velvet/(?:velvet/)?' '$1<VELVET>/' (all) |
      assertions:should-be $expected-log
  }
}