use str
use ./map

fn is-fail { |&with-content=$nil &partial=$true e|
  var reason = (map:get-value $e reason)

  if (not $reason) {
    put $false
    return
  }

  var type = (map:get-value $reason type)
  if (not-eq $type fail) {
    put $false
    return
  }

  if (not $with-content) {
    put $true
    return
  }

  var content = (map:get-value $reason content)

  if $partial {
    str:contains $content $with-content
  } else {
    ==s $content $with-content
  }
}

fn get-fail-message { |potential-exception|
  if (is-fail $potential-exception) {
    put $potential-exception[reason][content]
  } else {
    put $nil
  }
}