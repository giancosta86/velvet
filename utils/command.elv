fn -bytes-as-string { |block|
  $block 2>&1 | only-bytes | slurp
}

fn capture { |block|
  var status = $ok

  var output = (
    -bytes-as-string {
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