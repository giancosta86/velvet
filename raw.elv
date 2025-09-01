use os
use github.com/giancosta86/aurora-elvish/console

fn -test { |title block|
  console:echo ▶ $title
  $block > $os:dev-null 2>&1
}

fn -assert { |predicate|
  if (not $predicate) {
    fail 'Assertion failed!'
  }
}

fn suite { |title block|
  console:echo

  console:section &emoji=🎭 (styled $title bold) {
    $block $-test~ $-assert~

    echo ✅ All the tests for this section are OK!
  }
}