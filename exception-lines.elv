use path
use re
use str

var -cause-prefix = '  Exception: '

var -cause-leading-spaces = (str:index $-cause-prefix Exception)

var -first-clockwork-line-pattern = (
  all [
    ['ethereal' 'v\d+' 'command\.elv']

    ['velvet' 'v\d+' 'test-script\.elv']

    ['velvet' 'test-script\.elv']

    ['velvet' 'v\d+' 'sandbox\.elv']

    ['velvet' 'sandbox\.elv']
  ] |
    each { |path-component-list|
      path:join $@path-component-list
    } |
    str:join '|'
)

fn try-to-extract-first-cause {
  var lines = [(all)]

  var first-cause-found = $false

  all $lines | each { |line|
    if (str:has-prefix $line $-cause-prefix) {
      if $first-cause-found {
        break
      } else {
        set first-cause-found = $true
        put $line[$-cause-leading-spaces..]
      }
    } else {
      if $first-cause-found {
        put $line[$-cause-leading-spaces..]
      }
    }
  }

  if (not $first-cause-found) {
    all $lines
  }
}

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

  all $lines | each { |line|
    var generic-eval-pattern = '^\s*(\[eval\s+\d+\]):\d+?:\d+?.*?:'

    var find-result = [(re:find $generic-eval-pattern $line)]

    if (not-eq $find-result []) {
      set last-eval = $find-result[0][groups][1][text]
    }
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