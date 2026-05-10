use str
use github.com/giancosta86/ethereal/v1/command
use github.com/giancosta86/ethereal/v1/string
use ./throws

fn -replay-capture-result {
  var capture-result = (one)

  all $capture-result[data]

  if (not-eq $capture-result[exception] $nil) {
    fail $capture-result[exception]
  }
}

fn -process-style { |styled|
  var text = (one)

  if $styled {
    put $text
  } else {
    string:unstyled $text
  }
}

fn capture { |&throws=$false &styled=$false &stream=both &type=both block|
  var capturing-block = {
    command:capture &stream=$stream &type=$type $block |
      -replay-capture-result
  }

  if $throws {
    throws:throws &swallow $capturing-block
  } else {
    $capturing-block
  } |
    each $to-string~ |
      str:join "\n" |
      -process-style $styled
}
