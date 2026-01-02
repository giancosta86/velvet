fn report { |target-file|
  put { |summary|
    put $summary |
      to-json > $target-file
  }
}