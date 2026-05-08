use path
use re
use str
use github.com/giancosta86/ethereal/v1/seq
use github.com/giancosta86/ethereal/v1/string
use ./reporting/console/full
use ./reporting/console/terse
use ./reporting/json
use ./reporting/spy
use ./summary
use ./tests/aggregator/summaries
use ./tests/script-gallery
use ./velvet

var this-script-dir = (path:dir (src)[name])

fn get-aggregator-script { |basename|
  script-gallery:get-script-path aggregator $basename
}

>> 'Listing all the test scripts' {
  >> 'in directory with no tests' {
    tmp pwd = (path:join $this-script-dir docs)

    velvet:get-test-scripts |
      should-emit []
  }

  >> 'in directory with tests' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    var expected-scripts = [(
      all $script-gallery:aggregator |
        each $path:base~
    )]

    velvet:get-test-scripts |
      order |
      should-emit $expected-scripts
  }

  >> 'in directory with nested tests' {
    tmp pwd = (path:join $this-script-dir tests)

    velvet:get-test-scripts |
      order |
      should-emit $script-gallery:all
  }
}

>> 'Resolving test scripts' {
  tmp pwd = (path:join $this-script-dir tests)

  >> 'when requesting no scripts' {
    all [] |
      velvet:-resolve-test-scripts |
      should-emit $script-gallery:all
  }

  >> 'when requesting scripts without file extensions' {
    all [
      (path:join readme maths)
    ] |
      velvet:-resolve-test-scripts |
      should-be (path:join readme maths.test.elv)
  }

  >> 'when requesting directories' {
    all [
      readme
    ] |
      velvet:-resolve-test-scripts |
      should-be (path:join readme maths.test.elv)
  }

  >> 'when there is ambiguity between a test script and a directory' {
    fs:with-temp-dir { |temp-dir|
      cd $temp-dir

      echo '
      >> In script {
        put 90 |
          should-be 90
      }
      ' > ciop.test.elv

      fs:mkcd ciop

      echo '
      >> Failing test {
        fail KABOOM
      }
      ' > nested.test.elv

      cd ..

      all [
        ciop
      ] |
        velvet:-resolve-test-scripts |
        should-be ciop.test.elv
    }
  }
}

>> 'velvet command' {
  >> 'running one aggregator script' {
    >> 'with a single reporter' {
      var spy = (spy:create)

      velvet:velvet &reporters=[$spy[reporter]] (get-aggregator-script alpha)

      $spy[get-summary] |
        should-be $summaries:alpha
    }

    >> 'with multiple reporters' {
      var spies = [(
        range 1 3 |
          each { |_| spy:create }
      )]

      var reporters = [(
        all $spies |
          each (seq:make-getter reporter)
      )]

      get-aggregator-script alpha |
        velvet:velvet &reporters=$reporters (all)

      all $spies | each { |spy|
        $spy[get-summary] |
          should-be $summaries:alpha
      }
    }
  }

  >> 'running two aggregator scripts' {
    var spy = (spy:create)

    all [
      (get-aggregator-script alpha)
      (get-aggregator-script beta)
    ] |
      velvet:velvet &reporters=[$spy[reporter]] (all)

    $spy[get-summary] |
      should-be $summaries:alpha-beta
  }

  >> 'running all aggregator scripts via inference' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    var spy = (spy:create)

    velvet:velvet &reporters=[$spy[reporter]]

    $spy[get-summary] |
      summary:simplify |
      should-be $summaries:alpha-beta-gamma-simplified
  }

  >> 'running all aggregator tests and asserting success' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    fails {
      velvet:velvet &flawless &reporters=[]
    } |
      should-be '❌ There are flaws in the tests!'
  }

  >> 'running all the aggregator tests and requesting a summary' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    velvet:velvet &emit-summary &reporters=[] |
      summary:simplify |
      should-be $summaries:alpha-beta-gamma-simplified
  }

  >> 'running all the aggregator tests' {
    fn run-with-console-reporter { |reporter expected-log-name|
      tmp pwd = (path:join $this-script-dir tests aggregator)

      var expected-log-path = (path:join $this-script-dir tests aggregator terse.log)

      var expected-log = (slurp < $expected-log-path)

      velvet:velvet |
        slurp |
        string:unstyled |
        str:trim-space (all) |
        re:replace '([ \t]*?)\S+?/velvet/(?:velvet/)?' '$1<VELVET>/' (all) |
        should-be $expected-log
    }

    >> 'with the terse console reporter' {
      run-with-console-reporter $terse:report~ terse.log
    }

    >> 'with the full console reporter' {
      run-with-console-reporter $full:report~ full.log
    }

    >> 'with the JSON reporter' {
      tmp pwd = (path:join $this-script-dir tests aggregator)

      var spy = (spy:create)

      fs:with-temp-file { |json-report-path|
        var json-reporter = (json:report $json-report-path)

        velvet:velvet &flawless=$false &reporters=[$json-reporter $spy[reporter]]

        from-json < $json-report-path |
          should-be ($spy[get-summary])
      }
    }
  }

  >> 'verbose flag' {
    fn with-empty-test { |&verbose=$false block|
      var test-title = 'Just an empty test'

      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        printf '>> ''%s'' { }' $test-title > basic.test.elv

        capture {
          velvet:velvet &verbose=$verbose
        } |
          $block (all) $test-title
      }
    }

    >> 'when disabled' {
      with-empty-test { |output test-title|
        put $output |
          should-not-contain $test-title
      }
    }

    >> 'when enabled' {
      with-empty-test &verbose { |output test-title|
        put $output |
          should-contain $test-title
      }
    }
  }
}