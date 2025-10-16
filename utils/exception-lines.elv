use re
use str

fn trim-clockwork-stack {
  each { |line|
    if (
      str:trim-space $line |
        str:contains (all) '/velvet/utils/command.elv:11:9-14'
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

    if (== (count $find-result) 0) {
      continue
    }

    set last-eval = $find-result[0][groups][1][text]
  }

  if (not $last-eval) {
    all $lines
  } else {
    var specific-eval-pattern = '^\s*'(re:quote $last-eval)

    all $lines | each { |line|
      re:replace $specific-eval-pattern $replacement $line
    }
  }
}