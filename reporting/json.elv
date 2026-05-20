fn create-reporter { |target-file|
  put { |summary|
    put $summary |
      to-json > $target-file
  }
}