use ./assertion
use ./raw
use ./string

raw:suite 'Minimal string' { |test~|
  test 'With string' {
    eq (string:get-minimal Dodo) Dodo |
      assertion:assert (all)
  }

  test 'With number' {
    eq (string:get-minimal (num 90)) 90 |
      assertion:assert (all)
  }

  test 'With bool' {
    eq (string:get-minimal $false) '$false' |
      assertion:assert (all)
  }

  test 'With list' {
    eq (string:get-minimal [A (num 90) (num 92)]) '[A 90 92]' |
      assertion:assert (all)
  }

  test 'With map' {
    eq (string:get-minimal [&(num 90)=(num 92)]) '[&90=92]' |
      assertion:assert (all)
  }
}

raw:suite 'Indenting lines' { |test~|
  test 'With empty string' {
    string:indent-lines '' '****' |
      eq (all) '' |
      assertion:assert (all)
  }

  test 'With single text line' {
    string:indent-lines 'Alpha' '****' |
      eq (all) '****Alpha' |
      assertion:assert (all)
  }

  test 'With 2 text lines' {
    string:indent-lines "Alpha\nBeta" '****' |
      eq (all) "****Alpha\n****Beta" |
      assertion:assert (all)
  }

  test 'With 2 text lines and final empty line' {
    string:indent-lines "Alpha\nBeta\n" '****' |
      eq (all) "****Alpha\n****Beta\n" |
      assertion:assert (all)
  }

  test 'With 2 text lines and intermediate empty lines' {
    string:indent-lines "Alpha\n\n\nBeta" '****' |
      eq (all) "****Alpha\n\n\n****Beta" |
      assertion:assert (all)
  }

  test 'With 3 text lines, intermediate empty lines and final empty lines' {
    string:indent-lines "Alpha\n\n\nBeta\n\n\n\n\nGamma\n\n" '****' |
      eq (all) "****Alpha\n\n\n****Beta\n\n\n\n\n****Gamma\n\n" |
      assertion:assert (all)
  }
}