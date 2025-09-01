use github.com/giancosta86/aurora-elvish/console

fn -test { |title block|
  console:print ▶️ $title' '
  $block
  console:echo ✅
}

fn -assert { |predicate failure-message|
  if (not $predicate) {
    fail $failure-message
  }
}

fn suite { |title block|
  console:echo

  console:section &emoji=🎭 (styled $title bold) {
    $block $-test~ $-assert~

    echo ✅ All the tests for this section are OK!
  }
}