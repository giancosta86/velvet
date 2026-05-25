use github.com/giancosta86/ethereal/v1/fs
use github.com/giancosta86/ethereal/v1/lang

fn run-dual { |@arguments|
  lang:get-single-input $arguments |
    put (all)[name] |
    fs:get-script-subject |
    put (all)'.elv' |
    elvish -norc (all)
}