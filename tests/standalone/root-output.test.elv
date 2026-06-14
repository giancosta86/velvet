echo Hello!
echo World!
echo This is from stderr! >&2

>> 'Tests' {
  >> 'passing' {
    echo Wiii
  }

  >> 'failing' {
    echo Wooo

    fail DODO
  }
}