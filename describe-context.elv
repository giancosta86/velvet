use str
use github.com/giancosta86/aurora-elvish/command
use github.com/giancosta86/aurora-elvish/exception
use github.com/giancosta86/aurora-elvish/lang
use ./core
use ./describe-context-map
use ./outcomes

fn -create { |describe-path|
  var title = $describe-path[-1]
  var outcomes = [&]
  var sub-contexts = [&]

  fn format-path { |subtitle|
    str:join ' -> ' [$@describe-path $subtitle]
  }

  put [
    &ensure-sub-context={ |subtitle|
      var ensure-result = (
        describe-context-map:ensure-context $sub-contexts $subtitle { -create [$@describe-path $subtitle] }
      )

      set sub-contexts = $ensure-result[updated-map]
      put $ensure-result[context]
    }

    &run-test={ |test-title block|
      if (has-key $outcomes $test-title) {
        fail 'Duplicated test: '(format-path $test-title)
      }

      var command-status = ?(
        command:silence-until-error &description=(styled (format-path $test-title) red bold) {
          try {
            $block
          } catch e {
            if (not (exception:is-return $e)) {
              $core:tracer[pprint] $e
              fail $e
            }
          }
        }
      )

      var outcome = (lang:ternary (eq $command-status $ok) $outcomes:passed $outcomes:failed)

      set outcomes = (assoc $outcomes $test-title $outcome)

      put $outcome
    }

    &to-outcome-context={
      put [
        &outcomes=$outcomes
        &sub-contexts=(describe-context-map:to-outcome-context $sub-contexts)
      ]
    }
  ]
}

fn create-root { |describe-title|
  -create [$describe-title]
}