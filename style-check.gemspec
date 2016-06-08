
Gem::Specification.new do |s|
  s.name        = 'style-check'
  s.version     = '0.15'
  s.date        = '2014-12-06'
  s.summary     = "Style checker for LaTeX"
  s.description = "style-check.rb searches latex-formatted text in search of forbidden phrases and
    prints error messages formatted as if from a compiler."
  s.authors     = ["Neil Spring"]
  s.email       = 'nspring@cs.umd.edu'
  s.files       = ["bin/style-check.rb", "lib/style-check.rb" ] + Dir["lib/rules/*"] 

  s.platform = Gem::Platform::RUBY     
  s.require_paths = [ 'lib' ]
  s.extensions = Dir['ext/**/extconf.rb']

  s.executables = [ "style-check.rb" ]
  s.test_files = Dir["test/**/test_*.rb"]
  s.homepage    =
    'http://www.scriptroute.org/'
  s.license       = 'GPL'
  s.post_install_message = "Now run: \n% style-check.rb *.tex"
end

# Local Variables:
# compile-command: "gem build style-check.gemspec"
# End:
