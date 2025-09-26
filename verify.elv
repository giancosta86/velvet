all [
  assertion
] | each { |basic-script-basename|
  elvish -norc ./utils/$basic-script-basename'.atomic.elv'
}

all [
  assertions
  test-result
  describe-result
  stats
  reporting/cli
  describe-context
  test-script
  sandbox
  aggregator
  main
] | each { |raw-script-basename|
    elvish -norc $raw-script-basename'.raw.elv'
  }