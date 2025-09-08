use github.com/giancosta86/aurora-elvish/command
use github.com/giancosta86/aurora-elvish/exception
use github.com/giancosta86/aurora-elvish/lang
use github.com/giancosta86/aurora-elvish/map
use github.com/giancosta86/aurora-elvish/seq
use ./outcomes

fn create {
  var tests = [&]
  var sub-contexts = [&]

  put [
    &ensure-sub-context={ |sub-title|
      var existing-context = (map:get-value $sub-contexts $sub-title)

      if $existing-context {
        put $existing-context
      } else {
        var new-context = (create)

        set sub-contexts = (assoc $sub-contexts $sub-title $new-context)

        put $new-context
      }
    }

    &run-test={ |test-title block|
      if (has-key $tests $test-title) {
        fail 'Duplicated test: '''$test-title"'"
      }

      var capture-result = (command:capture $block)

      var outcome = (
        lang:ternary (eq $capture-result[status] $ok) $outcomes:passed $outcomes:failed
      )

      var test = [
        &output=$capture-result[output]
        &outcome=$outcome
      ]

      set tests = (assoc $tests $test-title $test)
    }

    &to-result-context={
      var converted-sub-contexts = (
        map:map $sub-contexts { |sub-title sub-context|
          var result-context = ($sub-context[to-result-context])

          put [$sub-title $result-context]
        }
      )

      put [
        &tests=$tests
        &sub-contexts=$converted-sub-contexts
      ]
    }
  ]
}
