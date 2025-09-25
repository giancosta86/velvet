use builtin
use str

fn echo { |@rest|
  builtin:echo $@rest > &2
}

fn print { |@rest|
  builtin:print $@rest > &2
}

fn show-block { |&emoji=🔎 description block|
  echo $emoji' '$description

  $block >&2

  echo (str:repeat $emoji 3)
}
