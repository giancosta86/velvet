use str
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

raw:suite 'Unstyling a string' { |test~|
  test 'With non-styled string' {
    var source = 'This is just a basic string'

    string:unstyled $source |
      eq (all) $source |
      assertion:assert (all)
  }

  test 'With styled string' {
    echo (styled 'Hello' bold italic green), (styled 'this' italic) is just a (styled 'basic test' bold red) |
      string:unstyled (all) |
      eq (all) 'Hello, this is just a basic test' |
      assertion:assert (all)
  }
}

raw:suite 'Fancy string from value' { |test~|
  test 'Applied to single-line string' {
    var source = 'Hello, world!'

    string:fancy $source |
      eq (all) $source"\n" |
      assertion:assert (all)
  }

  test 'Applied to multi-line string' {
    var source = "Hello!\n   world!"

    string:fancy $source |
      eq (all) $source"\n" |
      assertion:assert (all)
  }

  test 'Applied to number' {
    string:fancy (num 90) |
      eq (all) "(num 90)\n" |
      assertion:assert (all)
  }

  test 'Applied to list' {
    string:fancy [A B C] |
      eq (all) "[\n A\n B\n C\n]\n" |
      assertion:assert (all)
  }

  test 'Applied to exception' {
    var exception = ?(fail DODO)

    string:fancy $exception |
      string:unstyled (all) |
      str:has-prefix (all) "Exception: DODO\n" |
      assertion:assert (all)
  }
}