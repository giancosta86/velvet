fn safe {
  put 92
}

fn with-use {
  use ./beta

  + (beta:g) 5
}

fn with-use-mod {
  var m = (use-mod './beta')

  + ($m[g~]) 8
}