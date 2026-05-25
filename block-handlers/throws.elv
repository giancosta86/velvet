fn throws { |&swallow=$false block|
  try {
    if $swallow {
      $block
    } else {
      # When not swallowing the exception, the only output
      # of the command must be the exception itself,
      # therefore the block output must be redirected to stderr,
      # which only supports bytes.
      $block | only-bytes >&2
    }
  } catch e {
    if (not $swallow) {
      put $e
    }
  } else {
    fail 'The given code block did not throw!'
  }
}