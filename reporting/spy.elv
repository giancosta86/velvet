fn create {
  var summary = $nil

  put [
    &get-summary={ put $summary }

    &reporter={ |external-summary| set summary = $external-summary }
  ]
}
