rockspec_format = '3.0'
package = "cnc-nvim"
version = "0.0.0"
source = {
  url = "git+https://github.com/tbourrely/cnc.nvim.git"
}
dependencies = {
  -- Add runtime dependencies here
  -- e.g. "plenary.nvim",
}
test_dependencies = {
  "nlua"
}
build = {
  type = "builtin",
  copy_directories = {
    -- Add runtimepath directories, like
    -- 'plugin', 'ftplugin', 'doc'
    -- here. DO NOT add 'lua' or 'lib'.
  },
}
