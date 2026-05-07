use github.com/giancosta86/ethereal/v1/diff
use github.com/giancosta86/ethereal/v1/string

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
    diff:diff $formatted-green $formatted-red |
      tail -n +3
    echo 🔎🔎🔎
  }
}

fn highlight-wrong { |description value|
  echo (styled $description':' red bold)
  echo (string:pretty $value)
}