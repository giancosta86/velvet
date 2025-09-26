fn -take-bytes { |block|
  $block 2>&1 | only-bytes | slurp
}

fn capture { |block|
  var status = $ok

  var output = (
    -take-bytes {
      try {
        $block
      } catch e {
        set status = $e
      }
    }
  )

  put [
    &status=$status
    &output=$output
  ]
}