use path
use re
use str
use github.com/giancosta86/ethereal/v1/seq
use ./reporting/console/full
use ./reporting/console/terse
use ./reporting/json
use ./reporting/spy
use ./summary
use ./tests/aggregator/summaries
use ./tests/script-gallery
use ./velvet

var this-script-dir = (path:dir (src)[name])

>> 'velvet command' {
  >> 'resolving script path' {
    fn create-test-script {
      echo '' > alpha.test.elv
    }

    fn create-test-dir {
      mkdir alpha

      echo '' > alpha/beta.test.elv
      echo '' > alpha/gamma.test.elv
    }

    >> 'when the script path exists' {
      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        create-test-script

        velvet:-resolve-script-path alpha.test.elv |
          should-be alpha.test.elv
      }
    }

    >> 'when the script path does not exist' {
      >> 'when a file with test extension exists' {
        fs:with-temp-dir { |temp-dir|
          cd $temp-dir

          create-test-script

          velvet:-resolve-script-path alpha |
            should-be alpha.test.elv
        }
      }

      >> 'when a directory having the same name exists' {
        fs:with-temp-dir { |temp-dir|
          cd $temp-dir

          create-test-dir

          velvet:-resolve-script-path alpha |
            should-emit [
              (path:join alpha beta.test.elv)
              (path:join alpha gamma.test.elv)
            ]
        }
      }

      >> 'when both a file with test extension and a directory exist' {
        fs:with-temp-dir { |temp-dir|
          cd $temp-dir

          create-test-script

          create-test-dir

          velvet:-resolve-script-path alpha |
            should-be alpha.test.elv
        }
      }

      >> 'when neither a file with test extension nor a directory exist' {
        fs:with-temp-dir { |temp-dir|
          cd $temp-dir

          create-test-script

          create-test-dir

          velvet:-resolve-script-path beta |
            should-be beta
        }
      }
    }
  }

  >> 'resolving test scripts' {
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

        mkdir ciop

        echo '
        >> Failing test {
          fail KABOOM
        }
        ' > (path:join ciop nested.test.elv)

        all [
          ciop
        ] |
          velvet:-resolve-test-scripts |
          should-be ciop.test.elv
      }
    }
  }

  >> 'running one aggregator script' {
    >> 'with a single reporter' {
      var spy = (spy:create)

      velvet:velvet &reporters=[$spy[reporter]] (script-gallery:get-aggregator-script alpha)

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

      script-gallery:get-aggregator-script alpha |
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
      (script-gallery:get-aggregator-script alpha)
      (script-gallery:get-aggregator-script beta)
    ] |
      velvet:velvet &reporters=[$spy[reporter]] (all)

    $spy[get-summary] |
      should-be $summaries:alpha-beta
  }

  >> 'running all aggregator scripts' {
    tmp pwd = (path:join $this-script-dir tests aggregator)

    >> 'when running them via inference' {
      var spy = (spy:create)

      velvet:velvet &reporters=[$spy[reporter]]

      $spy[get-summary] |
        summary:simplify |
        should-be $summaries:alpha-beta-gamma-simplified
    }

    >> 'when asserting success' {
      fails {
        velvet:velvet &flawless &reporters=[]
      } |
        should-be '❌ There are flaws in the tests!'
    }

    >> 'when requesting a summary' {
      velvet:velvet &emit-summary &reporters=[] |
        summary:simplify |
        should-be $summaries:alpha-beta-gamma-simplified
    }

    >> 'when testing reporters' {
      fn run-with-console-reporter { |reporter expected-log-name|
        var expected-log-path = (path:join $this-script-dir tests aggregator $expected-log-name)

        var expected-log = (slurp < $expected-log-path)

        capture {
          velvet:velvet &reporters=[$reporter]
        } |
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
        var spy = (spy:create)

        fs:with-temp-file { |json-report-path|
          var json-reporter = (json:report $json-report-path)

          velvet:velvet &reporters=[$json-reporter $spy[reporter]]

          from-json < $json-report-path |
            should-be ($spy[get-summary])
        }
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
          $block $test-title (all)
      }
    }

    >> 'when disabled' {
      with-empty-test { |test-title output|
        put $output |
          should-not-contain $test-title
      }
    }

    >> 'when enabled' {
      with-empty-test &verbose { |test-title output|
        put $output |
          should-contain $test-title
      }
    }
  }
}