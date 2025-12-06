use path
use re
use str
use github.com/giancosta86/ethereal/v1/string
use ./main
use ./summary
use ./tests/aggregator/summaries
use ./tests/script-gallery

var this-script-dir = (path:dir (src)[name])
var dir-with-no-tests = (path:join $this-script-dir docs)

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

>> 'Listing test scripts' {
  >> 'in directory with no tests' {
    tmp pwd = $dir-with-no-tests

    main:get-test-scripts |
      put [(all)] |
      should-be []
  }

  >> 'in directory with tests' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    var expected-scripts = [(
      all $script-gallery:aggregator |
        each $path:base~
    )]

    main:get-test-scripts |
      order |
      put [(all)] |
      should-be $expected-scripts
  }

  >> 'in directory with nested tests' {
    tmp pwd = (path:join $this-script-dir tests)

    main:get-test-scripts |
      order |
      put [(all)] |
      should-be $script-gallery:all
  }
}

>> 'Boolean detection of test scripts' {
  >> 'in directory with no tests' {
    tmp pwd = $dir-with-no-tests

    main:has-test-scripts |
      should-be $false
  }

  >> 'in directory with tests' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    main:has-test-scripts |
      should-be $true
  }

  >> 'in directory having nested tests' {
    tmp pwd = (path:join $this-script-dir tests)

    main:has-test-scripts |
      should-be $true
  }
}

>> 'Top-level command' {
  >> 'running one aggregator script' {
    var spy = (create-reporter-spy)

    main:velvet &reporters=[$spy[reporter]] (get-test-script alpha)

    $spy[get-summary] |
      should-be $summaries:alpha
  }

  >> 'running two aggregator scripts' {
    var spy = (create-reporter-spy)

    main:velvet &reporters=[$spy[reporter]] (get-test-script alpha) (get-test-script beta)

    $spy[get-summary] |
      should-be $summaries:alpha-beta
  }

  >> 'running all aggregator scripts via inference' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    var spy = (create-reporter-spy)

    main:velvet &reporters=[$spy[reporter]]
    $spy[get-summary] |
      summary:simplify (all) |
      should-be $summaries:alpha-beta-gamma-simplified
  }

  >> 'running all aggregator tests and asserting success' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    throws {
      main:velvet &must-pass &reporters=[]
    } |
      get-fail-content |
      should-be '❌ There are failed tests!'
  }

  >> 'running all the aggregator tests and requesting a summary' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    main:velvet &put &reporters=[] |
      summary:simplify (all) |
      should-be $summaries:alpha-beta-gamma-simplified
  }

  >> 'running all the aggregator tests and checking the byte output' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    var home-directory = (put ~)

    var expected-log-path = (path:join $this-script-dir tests aggregator all.log)

    var expected-log = (slurp < $expected-log-path)

    main:velvet |
      slurp |
      string:unstyled (all) |
      str:trim-space (all) |
      re:replace '([ \t]*?)\S+?/velvet/(?:velvet/)?' '$1<VELVET>/' (all) |
      should-be $expected-log
  }
}