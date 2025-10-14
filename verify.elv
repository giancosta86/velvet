fn run-script { |script-path|
  elvish -norc $script-path
}

all [
  assertion
  exception
  command
  raw
] | each { |atomic-script-basename|
  run-script utils/$atomic-script-basename'.atomic.elv'
}

all [
  lang
  fs
  map
  string
  diff
  seq
] | each { |raw-script-basename|
  run-script utils/$raw-script-basename'.raw.elv'
}

all [
  assertions
  # test-result
  # describe-result
  # stats
  # reporting/cli
  # describe-context
  # test-script
  # sandbox
  # aggregator
  # main
] | each { |raw-script-basename|
    run-script $raw-script-basename'.raw.elv'
  }