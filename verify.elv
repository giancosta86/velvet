use path

fn run-script { |script-path|
  elvish -norc $script-path
}

all [
  assertion
  raw
] | each { |atomic-script-basename|
  run-script (path:join utils $atomic-script-basename'.atomic.elv')
}

all [
  exception-lines
  assertions
  test-result
  section
  stats
  summary
  reporting/console
  test-script-frame
  test-script
  sandbox
  aggregator
  main
] | each { |raw-script-basename|
  run-script $raw-script-basename'.raw.elv'
}

all [
  maths
] | each { |raw-script-basename|
  run-script (path:join tests readme $raw-script-basename'.raw.elv')
}