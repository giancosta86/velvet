use re

fn indent-lines { |indent|
  to-lines |
    each { |line|
      if (eq $line '') {
        echo
      } else {
        echo $indent''$line
      }
    } |
    slurp |
    put (all)[..-1]
}

fn unstyled { |source|
  re:replace '\x1b\[[0-9;]*m' '' $source
}

fn fancy { |value|
  var kind = (kind-of $value)

  if (eq $kind string) {
    echo $value
  } elif (eq $kind exception) {
    show $value
  } else {
    pprint $value
  } |
    slurp
}