use ./section
use ./stats

fn from-section { |section|
  var stats = (stats:from-section $section)

  put [
    &section=$section
    &stats=$stats
  ]
}

fn simplify { |summary|
  put [
    &section=(section:simplify $summary[section])
    &stats=$summary[stats]
  ]
}
