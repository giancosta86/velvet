use os
use path
use ./utils/command
use ./utils/console

fn -test { |title block|
  echo ▶ $title

  var capture-result = (command:capture $block)

  if (not-eq $capture-result[status] $ok) {
    echo $capture-result[output]
    fail $capture-result[status]
  }
}

fn suite { |title block|
  echo

  console:section &emoji=🎭 (styled $title bold) {
    $block $-test~ | only-bytes

    echo ✅ This section is OK!
  }
}