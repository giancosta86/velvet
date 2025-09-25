use str

fn show-block { |&emoji=🔎 description block|
  echo $emoji' '$description >&2

  $block > &2

  echo (str:repeat $emoji 3) >&2
}
