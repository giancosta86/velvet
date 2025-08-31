use str
use github.com/giancosta86/aurora-elvish/command
use github.com/giancosta86/aurora-elvish/exception
use github.com/giancosta86/aurora-elvish/lang
use github.com/giancosta86/aurora-elvish/map
use github.com/giancosta86/aurora-elvish/seq
use ./core
use ./outcomes

fn ensure-in-map { |map title factory|
  var existing-context = (map:get-value $map $title)

  if $existing-context {
    put [
      &context=$existing-context
      &updated-map=$map
    ]
  } else {
    var new-context = ($factory)

    var updated-map = (assoc $map $title $new-context)

    put [
      &context=$new-context
      &updated-map=$updated-map
    ]
  }
}

fn get-outcome-context { |context-map|
  var result = (map:entries $context-map |
    seq:each-spread { |describe-title context|
      var outcome-context = ($context[get-outcome-context])

      put [$describe-title $outcome-context]
    } |
    make-map)

  put $result
}

fn -create { |describe-path|
  var title = $describe-path[-1]
  var outcomes = [&]
  var sub-contexts = [&]

  fn format-path { |title|
    str:join ' -> ' [$@describe-path $title]
  }

  put [
    &ensure-sub-context={ |describe-title|
      var ensure-result = (
        ensure-in-map $sub-contexts $describe-title { -create [$@describe-path $describe-title] }
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

    &get-outcome-context={
      put [
        &outcomes=$outcomes
        &sub-contexts=(get-outcome-context $sub-contexts)
      ]
    }
  ]
}

fn create-root { |describe-title|
  -create [$describe-title]
}