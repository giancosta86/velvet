use github.com/giancosta86/ethereal/v1/diff
use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/string

fn with-strict-prefix { |&strict=$true @arguments|
  var message = (lang:get-single-input $arguments)

  var strictness-prefix = (
    if $strict {
      put 'strict '
    } else {
      put ''
    }
  )

  put $strictness-prefix''$message
}

fn get-minimal { |&strict=$true @arguments|
  var value = (lang:get-single-input $arguments)

  if $strict {
    put $value
  } else {
    lang:flat-num $value
  }
}

fn fail-with-strict-prefix { |&strict=$true @arguments|
  lang:get-single-input $arguments |
    with-strict-prefix &strict=$strict |
    fail (all)
}

fn contrast { |inputs|
  var red-description = $inputs[red-description]
  var red = $inputs[red]
  var green-description = $inputs[green-description]
  var green = $inputs[green]
  var show-diff = $inputs[show-diff]

  var formatted-red = (string:pretty $red)
  var formatted-green = (string:pretty $green)

  echo (styled $red-description':' red bold)
  echo $formatted-red

  echo (styled $green-description':' green bold)
  echo $formatted-green

  if $show-diff {
    echo 🔎 (styled DIFF: yellow bold)
    diff:diff $formatted-red $formatted-green |
      tail -n +3
    echo 🔎🔎🔎
  }
}

fn get-minimals { |&strict=$true argument|
  var piped = (one)

  get-minimal &strict=$strict $piped

  get-minimal &strict=$strict $argument
}

fn create-expect-failure { |assertion-function error-message-base|
  var expect-failure = { |&strict=$false pipe-operand argument-operand|
    use ./fails
    use ./should-be

    fails:fails {
      if (lang:is-function $pipe-operand) {
        $pipe-operand
      } else {
        put $pipe-operand
      } |
        $assertion-function &strict=$strict $argument-operand
    } |
      should-be:should-be (with-strict-prefix &strict=$strict $error-message-base)
  }

  put $expect-failure
}