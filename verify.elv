use path

fn run-script { |script-path|
  elvish -norc $script-path
}

all [
  assertion
  exception
  command
  raw
] | each { |atomic-script-basename|
  run-script (path:join utils $atomic-script-basename'.atomic.elv')
}

all [
  lang
  fs
  map
  string
  diff
  seq
  exception-lines
] | each { |raw-script-basename|
  run-script (path:join utils $raw-script-basename'.raw.elv')
}

all [
  assertions
  test-result
  section
  stats
  summary
  reporting/cli
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