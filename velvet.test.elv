use path
use re
use str
use github.com/giancosta86/ethereal/v1/string
use ./reporting/console/full
use ./reporting/json
use ./reporting/spy
use ./summary
use ./tests/aggregator/summaries
use ./tests/script-gallery
use ./velvet

var this-script-dir = (path:dir (src)[name])
var dir-with-no-tests = (path:join $this-script-dir docs)

fn get-test-script { |basename|
  script-gallery:get-script-path aggregator $basename
}

>> 'Listing test scripts' {
  >> 'in directory with no tests' {
    tmp pwd = $dir-with-no-tests

    velvet:get-test-scripts |
      put [(all)] |
      should-be []
  }

  >> 'in directory with tests' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    var expected-scripts = [(
      all $script-gallery:aggregator |
        each $path:base~
    )]

    velvet:get-test-scripts |
      order |
      put [(all)] |
      should-be $expected-scripts
  }

  >> 'in directory with nested tests' {
    tmp pwd = (path:join $this-script-dir tests)

    velvet:get-test-scripts |
      order |
      put [(all)] |
      should-be $script-gallery:all
  }
}

>> 'Detecting test scripts' {
  tmp pwd = (path:join $this-script-dir tests)

  >> 'when requesting no scripts' {
    velvet:-detect-test-scripts [] |
      should-emit $script-gallery:all
  }

  >> 'when requesting directories' {
    velvet:-detect-test-scripts [readme] |
      should-emit [
        (path:join readme maths.test.elv)
      ]
  }
}

>> 'Boolean detection of test scripts' {
  >> 'in directory with no tests' {
    tmp pwd = $dir-with-no-tests

    velvet:has-test-scripts |
      should-be $false
  }

  >> 'in directory with tests' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    velvet:has-test-scripts |
      should-be $true
  }

  >> 'in directory having nested tests' {
    tmp pwd = (path:join $this-script-dir tests)

    velvet:has-test-scripts |
      should-be $true
  }
}

>> 'Top-level command' {
  >> 'running one aggregator script' {
    >> 'with a single reporter' {
      var spy = (spy:create)

      velvet:velvet &reporters=[$spy[reporter]] (get-test-script alpha)

      $spy[get-summary] |
        should-be $summaries:alpha
    }

    >> 'with multiple reporters' {
      var spies = [(
        range 1 3 |
          each { |_| spy:create }
      )]

      var reporters = [(
        all $spies | each { |spy|
          put $spy[reporter]
        }
      )]

      velvet:velvet &reporters=$reporters (get-test-script alpha)

      all $spies | each { |spy|
        $spy[get-summary] |
          should-be $summaries:alpha
      }
    }
  }

  >> 'running two aggregator scripts' {
    var spy = (spy:create)

    velvet:velvet &reporters=[$spy[reporter]] (get-test-script alpha) (get-test-script beta)

    $spy[get-summary] |
      should-be $summaries:alpha-beta
  }

  >> 'running all aggregator scripts via inference' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    var spy = (spy:create)

    velvet:velvet &reporters=[$spy[reporter]]
    $spy[get-summary] |
      summary:simplify (all) |
      should-be $summaries:alpha-beta-gamma-simplified
  }

  >> 'running all aggregator tests and asserting success' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    throws {
      velvet:velvet &must-pass &reporters=[]
    } |
      exception:get-fail-content |
      should-be '❌ There are failed tests!'
  }

  >> 'running all the aggregator tests and requesting a summary' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    velvet:velvet &put &reporters=[] |
      summary:simplify (all) |
      should-be $summaries:alpha-beta-gamma-simplified
  }

  >> 'running all the aggregator tests and checking the report output' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    var home-directory = (put ~)

    var expected-log-path = (path:join $this-script-dir tests aggregator terse.log)

    var expected-log = (slurp < $expected-log-path)

    velvet:velvet |
      slurp |
      string:unstyled (all) |
      str:trim-space (all) |
      re:replace '([ \t]*?)\S+?/velvet/(?:velvet/)?' '$1<VELVET>/' (all) |
      should-be $expected-log
  }

  >> 'running all the aggregator tests and checking the full report output' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    var home-directory = (put ~)

    var expected-log-path = (path:join $this-script-dir tests aggregator full.log)

    var expected-log = (slurp < $expected-log-path)

    velvet:velvet &must-pass=$false &reporters=[$full:report~] |
      slurp |
      string:unstyled (all) |
      str:trim-space (all) |
      re:replace '([ \t]*?)\S+?/velvet/(?:velvet/)?' '$1<VELVET>/' (all) |
      should-be $expected-log
  }

  >> 'running all the aggregator tests and checking the JSON report' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    var spy = (spy:create)

    fs:with-temp-file { |json-report-path|
      var json-reporter = (json:report $json-report-path)

      velvet:velvet &must-pass=$false &reporters=[$json-reporter $spy[reporter]]

      from-json < $json-report-path |
        should-be ($spy[get-summary])
    }
  }
}