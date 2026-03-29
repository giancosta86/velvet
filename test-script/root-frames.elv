use ../section

fn create {
  var frames = []

  fn append { |frame|
    set frames = (conj $frames $frame)
  }

  fn to-section {
    all $frames | each { |frame|
      var frame-title = $frame[title]

      var frame-artifact = ($frame[to-artifact])

      if (section:is-section $frame-artifact) {
        section:create [&] [&$frame-title=$frame-artifact]
      } else {
        section:create [&$frame-title=$frame-artifact]
      }
    } |
      section:merge
  }

  put [
    &append=$append~
    &to-section=$to-section~
  ]
}