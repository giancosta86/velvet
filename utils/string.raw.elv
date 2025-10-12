use ./assertion
use ./raw
use ./string

raw:suite 'Minimal string' { |test~|
  test 'With string' {
    string:get-minimal Dodo |
      eq (all) Dodo |
      assertion:assert (all)
  }

  test 'With number' {
    string:get-minimal (num 90) |
      eq (all) 90 |
      assertion:assert (all)
  }

  test 'With bool' {
    string:get-minimal $false |
      eq (all) '$false' |
      assertion:assert (all)
  }

  test 'With list' {
    string:get-minimal [A (num 90) (num 92)] |
      eq (all) '[A 90 92]' |
      assertion:assert (all)
  }

  test 'With map' {
    string:get-minimal [&(num 90)=(num 92)] |
      eq (all) '[&90=92]' |
      assertion:assert (all)
  }
}

raw:suite 'Indenting lines' { |test~|
  test 'With empty string' {
    put '' |
      string:indent-lines '****' |
      eq (all) '' |
      assertion:assert (all)
  }

  test 'With single text line' {
    put 'Alpha' |
      string:indent-lines '****' |
      eq (all) '****Alpha' |
      assertion:assert (all)
  }

  test 'With 2 text lines' {
      put "Alpha\nBeta" |
        string:indent-lines '****' |
        eq (all) "****Alpha\n****Beta" |
        assertion:assert (all)
  }

  test 'With 2 text lines and final empty line' {
    put "Alpha\nBeta\n" |
      string:indent-lines '****' |
      eq (all) "****Alpha\n****Beta\n" |
      assertion:assert (all)
  }

  test 'With 2 text lines and intermediate empty lines' {
    put "Alpha\n\n\nBeta" |
      string:indent-lines '****' |
      eq (all) "****Alpha\n\n\n****Beta" |
      assertion:assert (all)
  }

  test 'With 3 text lines, intermediate empty lines and final empty lines' {
    put "Alpha\n\n\nBeta\n\n\n\n\nGamma\n\n" |
      string:indent-lines '****' |
      eq (all) "****Alpha\n\n\n****Beta\n\n\n\n\n****Gamma\n\n" |
      assertion:assert (all)
  }
}