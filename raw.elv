use os
use path
use github.com/giancosta86/aurora-elvish/console
use github.com/giancosta86/aurora-elvish/command

fn -test { |title block|
  console:echo ▶ $title

  var capture-result = (command:capture $block)

  if (not-eq $capture-result[status] $ok) {
    echo $capture-result[output]
    fail $capture-result[status]
  }
}

fn suite { |title block|
  console:echo

  console:section &emoji=🎭 (styled $title bold) {
    $block $-test~ | only-bytes

    echo ✅ This section is OK!
  }
}

fn run-all {
  put **.raw.elv | each { |raw-test-path|
    tmp pwd = (path:dir $raw-test-path)

    elvish -norc (path:base $raw-test-path)
  }
}