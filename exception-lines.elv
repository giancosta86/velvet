use re

var -first-clockwork-line-pattern = '/ethereal/v1/command\.elv|/velvet/(?:v\d+/)?test-script\.elv'

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

  var generic-eval-pattern = '^\s*(\[eval\s+\d+\]):\d+?:\d+.*?:'

  all $lines | each { |line|
    var find-result = [(re:find $generic-eval-pattern $line)]

    if (eq $find-result []) {
      continue
    }

    set last-eval = $find-result[0][groups][1][text]
  }

  if (not $last-eval) {
    all $lines
  } else {
    var specific-eval-pattern = '^(\s*)'(re:quote $last-eval)

    all $lines | each { |line|
      re:replace $specific-eval-pattern '${1}'$replacement $line
    }
  }
}