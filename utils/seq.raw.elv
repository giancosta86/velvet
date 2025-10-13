use str
use ./assertion
use ./exception
use ./raw
use ./seq

raw:suite 'Splitting a sequence by chunk count' { |test~|
  test 'With chunk count < 0' {
    exception:expect-throws {
      all [Alpha Beta] |
        seq:split-by-chunk-count -1
    } |
      exception:get-fail-message (all) |
      str:contains (all) 'The chunk count must be > 0!' |
      assertion:assert (all)
  }

  test 'With chunk count 0' {
    exception:expect-throws {
      all [Alpha Beta] |
        seq:split-by-chunk-count 0
    } |
      exception:get-fail-message (all) |
      str:contains (all) 'The chunk count must be > 0!' |
      assertion:assert (all)
  }

  test 'With 1 chunk and 4 items' {
    all [Alpha Beta Gamma Delta] |
      seq:split-by-chunk-count 1 |
      eq [(all)] [[Alpha Beta Gamma Delta]] |
      assertion:assert (all)
  }

  test 'With 3 chunks and 0 items' {
    all [] |
      seq:split-by-chunk-count 3 |
      eq [(all)] [] |
      assertion:assert (all)
  }

  test 'With 3 chunks and 1 item' {
    all [Alpha] |
      seq:split-by-chunk-count 3 |
      eq [(all)] [[Alpha]] |
      assertion:assert (all)
  }

  test 'With 3 chunks and 2 items' {
    all [Alpha Beta] |
      seq:split-by-chunk-count 3 |
      eq [(all)] [[Alpha] [Beta]] |
      assertion:assert (all)
  }

  test 'With 3 chunks and 3 items' {
    all [Alpha Beta Gamma] |
      seq:split-by-chunk-count 3 |
      eq [(all)] [[Alpha] [Beta] [Gamma]] |
      assertion:assert (all)
  }

  test 'With 3 chunks and 4 items' {
    all [Alpha Beta Gamma Delta] |
      seq:split-by-chunk-count 3 |
      eq [(all)] [[Alpha Delta] [Beta] [Gamma]] |
      assertion:assert (all)
  }

  test 'With 3 chunks and 7 items' {
    all [Alpha Beta Gamma Delta Epsilon Zeta Eta] |
      seq:split-by-chunk-count 3 |
      eq [(all)] [[Alpha Delta Eta] [Beta Epsilon] [Gamma Zeta]] |
      assertion:assert (all)
  }
}