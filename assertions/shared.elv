use github.com/giancosta86/ethereal/v1/diff
use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/seq
use github.com/giancosta86/ethereal/v1/string
use ../assertion

fn get-minimal { |&strict=$true @arguments|
  var value = (lang:get-single-input $arguments)

  if $strict {
    put $value
  } else {
    lang:flat-num $value
  }
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

fn highlight-wrong-value { |description value|
  echo (styled $description':' red bold)
  echo (string:pretty $value)
}

fn get-minimals { |&strict=$true argument|
  var piped = (one)

  get-minimal &strict=$strict $piped

  get-minimal &strict=$strict $argument
}

fn create-assertion-testing-entries { |test failure-entries-description|
  var assertion-reference = (one)

  put {
    var failure-entries = [(
      each { |entry|
        if (not ($test $entry)) {
          put $entry
        }
      }
    )]

    if (seq:is-non-empty $failure-entries) {
      highlight-wrong-value $failure-entries-description $failure-entries

      assertion:fail $assertion-reference
    }
  }
}

fn equalize { |&strict=$false &order-key=$nil|
  each { |value|
    get-minimal &strict=$strict $value
  } |
    {
      if $order-key {
        order &key=$order-key
      } else {
        all
      }
    }
}