fn -test { |title test-block|
  echo ▶ $title

  $test-block
}

fn suite { |&emoji='⚛️ ' description suite-block|
  echo

  echo $emoji (styled $description bold)

  $suite-block $-test~ | only-bytes

  echo $emoji''✅
}