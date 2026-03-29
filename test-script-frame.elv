use str
use github.com/giancosta86/ethereal/v1/command
use github.com/giancosta86/ethereal/v1/exception
use github.com/giancosta86/ethereal/v1/seq
use ./exception-lines
use ./outcomes
use ./section
use ./test-result

fn create { |script-path title|
  var block-result = $nil
  var sub-frames = []

  fn run-block { |block|
    if $block-result {
      fail 'Block result already set in frame: '$title
    }

    set block-result = (command:capture &type=bytes $block)
  }

  fn add-sub-frame { |sub-frame|
    set sub-frames = (conj $sub-frames $sub-frame)
  }

  fn to-test-result {
    var exception = $block-result[exception]

    var test-passed = (
      or (eq $exception $nil) (exception:is-return $exception)
    )

    if $test-passed {
      test-result:success $block-result[data]
    } else {
      var exception-lines = [(
        show $exception |
          exception-lines:trim-clockwork-stack |
          exception-lines:replace-bottom-eval $script-path
      )]

      test-result:failure $block-result[data] $exception-lines
    }
  }

  fn to-section {
    all $sub-frames | seq:reduce $section:empty { |cumulated-section sub-frame|
      var sub-title = $sub-frame[title]

      var sub-artifact = ($sub-frame[to-artifact])

      if (section:is-section $sub-artifact) {
        section:add-sub-section $cumulated-section $sub-title $sub-artifact
      } else {
        section:add-test-result $cumulated-section $sub-title $sub-artifact
      }
    }
  }

  fn to-artifact {
    if (not $block-result) {
      fail 'Cannot obtain artifact when block result is not set, in frame: '$title
    }

    var is-section-frame = (seq:is-non-empty $sub-frames)

    if $is-section-frame {
      var exception = $block-result[exception]

      if (not-eq $exception $nil) {
        fail $exception
      }

      to-section
    } else {
      to-test-result
    }
  }

  put [
    &title=$title
    &add-sub-frame=$add-sub-frame~
    &run-block=$run-block~
    &to-artifact=$to-artifact~
  ]
}