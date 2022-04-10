plugin = Plugin.new('FOO', :tcp, 30000)
p plugin
p plugin.name
p plugin.filter_name
p plugin.protocol
p plugin.port

plugin.dissect { |plugin|
  subtree = plugin.add_subtree
  subtree.add_field
}
