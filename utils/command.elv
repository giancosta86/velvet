fn -bytes-as-string { |block|
  $block 2>&1 | only-bytes | slurp
}

fn capture { |block|
  var exception = $nil

  var output = (
    -bytes-as-string {
      try {
        $block
      } catch e {
        set exception = $e
      }
    }
  )

  put [
    &output=$output
    &exception=$exception
  ]
}