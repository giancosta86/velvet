use github.com/giancosta86/ethereal/v1/diff
use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/string

fn display-wrong { |description value|
  echo (styled $description':' red bold)
  echo (string:pretty $value)
}

fn contrast { |@arguments|
  var settings = (lang:get-single-input $arguments)

  var red-description = $settings[red-description]
  var red = $settings[red]
  var green-description = $settings[green-description]
  var green = $settings[green]
  var show-diff = $settings[show-diff]

  var formatted-red = (string:pretty $red)
  var formatted-green = (string:pretty $green)

  echo (styled $red-description':' red bold)
  echo $formatted-red

  echo (styled $green-description':' green bold)
  echo $formatted-green

  if $show-diff {
    echo 🔎 (styled DIFF: yellow bold)
    diff:diff $formatted-green $formatted-red |
      tail -n +3
    echo 🔎🔎🔎
  }
}