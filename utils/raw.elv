use github.com/giancosta86/ethereal/v1/command

fn -test { |test-title test-block|
  echo ▶ $test-title

  var capture-result = (command:capture &type=bytes $test-block)

  if (not-eq $capture-result[exception] $nil) {
    all $capture-result[data] |
      to-lines |
      slurp |
      echo (all)

    fail $capture-result[exception]
  }
}

fn suite { |suite-title suite-block|
  echo 🎭 (styled $suite-title bold)

  $suite-block $-test~

  echo 🎭✅
  echo
}