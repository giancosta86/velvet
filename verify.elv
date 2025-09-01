put **.raw.elv | each { |raw-test-path|
  elvish -norc $raw-test-path
}