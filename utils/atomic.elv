fn suite { |description block|
  echo '⚛️ ' (styled $description bold)

  $block
}