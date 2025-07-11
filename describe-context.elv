use str
use ../command
use ../console
use ../exception
use ../map
use ../seq

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

fn get-outcome-map { |context-map|
  map:entries $context-map |
    seq:each-spread { |describe-title context|
      put [$describe-title ($context[get-outcome-map])]
    } |
    make-map
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

      var outcome = ?(
        command:silence-until-error &description=(styled (format-path $test-title) red bold) {
          try {
            $block
          } catch e {
            if (not (exception:is-return $e)) {
              console:pprint $e
              fail $e
            }
          }
        }
      )

      set outcomes = (assoc $outcomes $test-title $outcome)

      put $outcome
    }

    &get-outcome-map={
      put [
        &outcomes=$outcomes
        &sub-contexts=(get-outcome-map $sub-contexts)
      ]
    }
  ]
}

fn create-root { |describe-title|
  -create [$describe-title]
}