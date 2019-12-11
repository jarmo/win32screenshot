require 'rdoc'
h = RDoc::Markup::ToMarkdown.new
puts h.convert(File.read(ARGV[0]))
