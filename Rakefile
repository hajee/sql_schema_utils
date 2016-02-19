require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
begin
  require_relative('../easy_type/lib/easy_type/docs')
rescue LoadError
  puts "No EasyType docs support"
end



# These two gems aren't always present, for instance
# on Travis with --without development
begin
  require 'puppet_blacksmith/rake_tasks'
rescue LoadError
end

# Prepend lib's fload path
current_path = Pathname(__FILE__).dirname
lib_path = current_path + 'lib'
$:.unshift(lib_path.to_s)

PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"
PuppetLint.configuration.fail_on_warnings = true

# Forsake support for Puppet 2.6.2 for the benefit of cleaner code.
# http://puppet-lint.com/checks/class_parameter_defaults/
PuppetLint.configuration.send('disable_class_parameter_defaults')
# http://puppet-lint.com/checks/class_inherits_from_params_class/
PuppetLint.configuration.send('disable_class_inherits_from_params_class')

exclude_paths = [
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths

desc "Run acceptance tests"
RSpec::Core::RakeTask.new(:acceptance) do |t|
  t.pattern = 'spec/acceptance'
end

desc "Run syntax, lint, and spec tests."
task :test => [
  :syntax,
  :lint,
  :spec,
]


desc "Create Markdown docs"
task :doc do
  include EasyType::Docs::ClassMethods
  File.open('./documentation/detailed-description.md','w') do | output|
    all_types =  Dir.glob('lib/puppet/type/*.rb').collect {|f| File.basename(f).split('.').first}
    output.puts toc(all_types)
    all_types.each {|t| output.puts generate_doc(t)}
  end
end



desc "Publish to forge on enterprismodules"
task :publish do
  file = Rake::FileList["./pkg/*.tar.gz"]
  system "scp #{file} forge@forge.enterprisemodules.com:~/modules" 
end


def generate_doc(type)
  STDERR.puts "Generating doc for #{type}..."
  type_name = type.capitalize
  require_relative('../easy_type/lib/easy_type/docs')
  require_relative "./lib/puppet/type/#{type}.rb"
  type_class = Puppet::Type.const_get(type_name)
  type_class.extend(EasyType::Docs)
  type_class.full_doc
end

