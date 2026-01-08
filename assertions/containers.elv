use str
use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/map
use github.com/giancosta86/ethereal/v1/set

fn -fail-display-should-contain { |inputs|
  var source-description = $inputs[source-description]
  var source = $inputs[source]
  var missing-value-description = $inputs[missing-value-description]
  var missing-value = $inputs[missing-value]
  var error-message = $inputs[error-message]

  echo (styled $missing-value-description':' red bold)
  echo (string:pretty $missing-value)

  echo (styled $source-description':' green bold)
  echo (string:pretty $source)

  fail $error-message
}

fn detect-kind { |@arguments|
  var container = (lang:get-single-input $arguments)

  if (set:is-set $container) {
    put ethereal-set
  } else {
    kind-of $container
  }
}

var -contains-by-container-kind = [
  &string={ |source-string sub-string| str:contains $source-string $sub-string }

  &list={ |source-list item| has-value $source-list $item }

  &map={ |source-map key| has-key $source-map $key }

  &ethereal-set={ |source-set item| set:has-value $source-set $item }
]

fn contains { |container item|
  var container-kind = (detect-kind $container)

  if (not (has-key $-contains-by-container-kind $container-kind)) {
    fail 'Unsupported container kind: '$container-kind
  }

  var implementation = $-contains-by-container-kind[$container-kind]

  $implementation $container $item
}

var -value-description-by-container-kind = [
  &string=substring
  &list=item
  &map=key
  &ethereal-set=item
]

fn get-value-description { |container|
  var container-kind = (detect-kind $container)

  if (not (has-key $-value-description-by-container-kind $container-kind)) {
    fail 'Unsupported container kind: '$container-kind
  }

  put $-value-description-by-container-kind[$container-kind]
}