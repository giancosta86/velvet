use builtin
use github.com/giancosta86/ethereal/v1/fs
use github.com/giancosta86/ethereal/v1/lang
use ./utils

var failure-prefix = 'Assertion failed: '

fn format-failure { |@arguments|
  var assertion-reference = (lang:get-single-input $arguments)

  var assertion-name = (
    if (eq (kind-of $assertion-reference) map) {
      put $assertion-reference[name] |
        fs:get-script-subject
    } else {
      put $assertion-reference
    }
  )

  put $failure-prefix''$assertion-name
}

fn fail { |@arguments|
  format-failure $@arguments |
    builtin:fail (all)
}