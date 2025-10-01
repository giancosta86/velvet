use path

fn get-path { |subdirectory basename|
  var this-script-dir = (path:dir (src)[name])

  path:join $this-script-dir $subdirectory $basename'.test.elv'
}