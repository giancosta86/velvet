fn throws { |&swallow=$false block|
  try {
    if $swallow {
      $block
    } else {
      $block | only-bytes >&2
    }
  } catch e {
    if (not $swallow) {
      put $e
    }
  } else {
    fail 'The given code block did not fail!'
  }
}