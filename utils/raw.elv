use ./command

fn -test { |title test-block|
  echo ▶ $title

  var capture-result = (command:capture $test-block)

  if (not-eq $capture-result[status] $ok) {
    echo $capture-result[output]
    fail $capture-result[status]
  }
}

fn suite { |&emoji=🎭 description suite-block|
  echo $emoji (styled $description bold)

  $suite-block $-test~ | only-bytes

  echo $emoji''✅
  echo
}