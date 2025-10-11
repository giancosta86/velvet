use ./command

fn -test { |test-title test-block|
  echo ▶ $test-title

  var capture-result = (command:capture $test-block)

  if (not-eq $capture-result[status] $ok) {
    echo $capture-result[output]
    fail $capture-result[status]
  }
}

fn suite { |suite-title suite-block|
  echo 🎭 (styled $suite-title bold)

  $suite-block $-test~

  echo 🎭✅
  echo
}