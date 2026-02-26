use github.com/giancosta86/ethereal/v1/lang

var -test-script-extension-length = (count '.test.elv')

fn -get-dual-script { |test-script-path|
  put $test-script-path[..-$-test-script-extension-length]'.elv'
}

fn run-dual { |@arguments|
  var test-src-data = (lang:get-single-input $arguments)

  var test-script-path = $test-src-data[name]

  var dual-script = (-get-dual-script $test-script-path)

  elvish -norc $dual-script
}