use re
use str

var -first-clockwork-line-mark = 'github.com/giancosta86/ethereal/v1/command.elv:'

fn trim-clockwork-stack {
  each { |line|
    if (
      str:trim-space $line |
        str:contains (all) $-first-clockwork-line-mark
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