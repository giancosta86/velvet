use str

fn section { |&emoji=🔎 description block|
  echo $emoji' '$description >&2

  $block > &2

  echo (str:repeat $emoji 3) >&2
}
