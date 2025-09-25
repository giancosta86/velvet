use os
use path
use ./command
use ./console

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

  console:show-block &emoji=🎭 (styled $title bold) {
    $block $-test~ | only-bytes

    echo ✅ This section is OK!
  }
}