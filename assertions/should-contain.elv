use ./containers
use ./shared

var -error-message-base = 'should-contain assertion failed'

fn should-contain { |&strict=$false value|
  var container value = (shared:get-minimals &strict=$strict $value)

  if (not (containers:contains $container $value)) {
    shared:contrast [
      &red-description='Expected '(containers:get-value-description $container)
      &red=$value
      &green-description='Actual '(containers:detect-kind $container)
      &green=$container
      &show-diff=$false
    ]

    shared:fail-with-strict-prefix &strict=$strict $-error-message-base
  }
}