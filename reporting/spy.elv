fn create {
  var current-summary = $nil

  put [
    &get-summary={ put $current-summary }

    &reporter={ |summary| set current-summary = $summary }
  ]
}
