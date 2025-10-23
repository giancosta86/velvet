>> 'My passing test' {
  echo Wiii!
  echo Wiii2! >&2
  put 90
}

>> 'My failing test' {
  echo Wooo!
  echo Wooo2! >&2
  put 90

  fail DODO
}