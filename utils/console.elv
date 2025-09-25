use str
use ./lang

fn section { |&emoji=🔎 description string-or-block|
  echo $emoji' '$description":"

  if (lang:is-function $string-or-block) {
    $string-or-block > &2
  } else {
    echo $string-or-block
  }

  echo (str:repeat $emoji 3)
}
