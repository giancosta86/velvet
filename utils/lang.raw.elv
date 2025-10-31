use ./assertion
use ./lang
use ./raw

raw:suite 'is-function test' { |test~|
  test 'On number' {
    lang:is-function (num 90) |
      not (all) |
      assertion:assert (all)
  }

  test 'On function' {
    lang:is-function { |x| + $x 1 } |
      assertion:assert (all)
  }
}

raw:suite 'Minimized value' { |test~|
  test 'For string' {
    var value = 'This is a string!'

    lang:minimize $value |
      eq (all) $value |
      assertion:assert (all)
  }

  test 'For number' {
    lang:minimize (num 90) |
      eq (all) '90' |
      assertion:assert (all)
  }

  test 'For boolean' {
    lang:minimize $true |
      eq (all) $true |
      assertion:assert (all)
  }

  test 'For $nil' {
    lang:minimize $nil |
      eq (all) $nil |
      assertion:assert (all)
  }

  test 'For exception' {
    var ex = ?(fail DODO)

    lang:minimize $ex |
      eq (all) $ex |
      assertion:assert (all)
  }

  test 'For list' {
    lang:minimize [
      Alpha
      (num 92)
      $nil
      $false
    ] |
      eq (all) [
        Alpha
        '92'
        $nil
        $false
      ] |
      assertion:assert (all)
  }

  test 'For multi-level list' {
    lang:minimize [
      Alpha
      [
        Beta
        [Gamma (num 95) Delta]
      ]
      $nil
      $false
    ] |
      eq (all) [
        Alpha
        [
          Beta
          [Gamma 95 Delta]
        ]
        $nil
        $false
      ] |
      assertion:assert (all)
  }

  test 'For map' {
    lang:minimize [
      &alpha=(num 90)
      &(num 92)=beta
    ] |
      eq (all) [
        &alpha=90
        &92=beta
      ] |
      assertion:assert (all)
  }

  test 'For multi-level map' {
    lang:minimize [
      &[alpha $true (num 95)]=[
        gamma
        [(num 98) epsilon]
        [&ro=[$nil (num 99)]]
      ]
    ] |
      eq (all) [
        &[alpha $true 95]=[
          gamma
          [98 epsilon]
          [&ro=[$nil 99]]
        ]
      ] |
      assertion:assert (all)
  }
}