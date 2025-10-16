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

  if (
    count $lines |
      eq (all) 0
  ) {
    put []
    return
  }

  var frame-stack-lines = $lines[..-1]

  var eval-line = $lines[-1]

  var updated-eval-line = (
    re:replace '\[eval\s+\d+\]:(\d+?):(\d+).*?:' $replacement':$1:$2:' $eval-line
  )

  all $frame-stack-lines

  put $updated-eval-line
}