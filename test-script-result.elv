use ./describe-result
use ./stats

fn merge { |left right|
  put [
    &describe-result=(describe-result:merge $left $right)
    &stats=(stats:merge $left $right)
  ]
}