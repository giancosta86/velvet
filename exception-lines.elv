use path
use re
use str

var -first-clockwork-line-pattern = (
  all [
    ['ethereal' 'v\d+' 'command\.elv']

    ['velvet' 'v\d+' 'test-script\.elv']

    ['velvet' 'test-script\.elv']
  ] |
    each { |path-component-list|
      path:join $@path-component-list
    } |
    str:join '|'
)

fn trim-clockwork-stack {
  each { |line|
    if (
      re:match $-first-clockwork-line-pattern $line
    ) {
      break
    }

    put $line
  }
}

fn replace-bottom-eval { |replacement|
  var lines = [(all)]

  var last-eval = $nil

  var generic-eval-pattern = '^\s*(\[eval\s+\d+\]):\d+?:\d+?.*?:'

  all $lines | each { |line|
    var find-result = [(re:find $generic-eval-pattern $line)]

    if (eq $find-result []) {
      continue
    }

    set last-eval = $find-result[0][groups][1][text]
  }

  if $last-eval {
    var specific-eval-pattern = '^(\s*)'(re:quote $last-eval)

    all $lines | each { |line|
      re:replace $specific-eval-pattern '${1}'$replacement $line
    }
  } else {
    all $lines
  }
}