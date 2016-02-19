require 'easy_type'
require 'fileutils'
require 'tmpdir'
require 'puppet_x/enterprisemodules/sqlserver/sql'

Puppet::Type.type(:sql_schema_definition).provide(:powershell) do
  include EasyType::Provider
  include EasyType::Template
  include EasyType::Helpers
  include Puppet_X::EnterpriseModules::Sqlserver::Sql

  desc "Manage The schema definition"

  mk_resource_methods

  def self.prefetch(resources)
    resources.each do |name, resource|
      options = options_for(resource[:schema_name], resource[:password], resource[:database_name])
      destroy(resource) if resource[:reinstall] == :true
      if version_table_exists?(resource, options)
        statement = template('puppet:///modules/sql_schema_utils/sql_schema_definition/index.sql.erb', binding)
        versions = sql(statement, options)
      else
        versions = []
      end
      if versions.empty?
        resource.provider = new(:ensure => :absent)
      else
        resource.provider = map_raw_to_resource(versions.last)
      end
      resource[:ensure] = resource.provider.latest_available_version if resource[:ensure] == :latest
      resource
    end
  end

  def self.version_table_exists?(resource, options)
    statement = template('puppet:///modules/sql_schema_utils/sql_schema_definition/version_table_exists.sql.erb', binding)
    rows = sql(statement, options)
    !rows.empty?
  end

  def self.options_for(username, password, database)
    options = {:database_name => database}
    options.merge!( :username => username)
    password = password.nil? ? username : password
    options.merge!( :password => password)
    options
  end

  def upgrade_to(version)
    check_upgrade_path
    copy_upgrade_scripts_to_tmp
    ensure_version_table
    scripts = scripts_for_upgrade(self.ensure, version)
    execute_scripts(scripts) do |script|
      sequence, application, version, description = parse_script_name(script)
      "insert into [#{resource[:database_name]}].[dbo].[schema_version] (id, application, version, description) values ('#{sequence}', '#{application}', '#{version}', '#{description}')"
    end
  end

  def downgrade_to(version)
    check_downgrade_path
    copy_downgrade_scripts_to_tmp
    ensure_version_table
    scripts = scripts_for_downgrade(self.ensure, version)
    execute_scripts(scripts) do | script|
      sequence, _, _, _ = parse_script_name(script)
      "delete from [#{resource[:database_name]}].[dbo].[schema_version] where RIGHT('000'+CAST(id AS VARCHAR(4)),4)='#{sequence}'"
    end
  end

  def self.destroy(resource)
    Puppet.info 'deleting all schema information'
    options = options_for(resource[:schema_name], resource[:password], resource[:database_name])
    options[:parse] = false
    statement = template('puppet:///modules/sql_schema_utils/sql_schema_definition/drop.sql.erb', binding)
    sql(statement, options)
  end

  def latest_available_version
    last_upgrade_script =  upgrade_scripts.last
    if last_upgrade_script
      _, _, version = parse_script_name(upgrade_scripts.last)
    else
      version = :latest
    end
    version
  end

  private 

  def copy_upgrade_scripts_to_tmp
    tmp_dir = Dir.tmpdir
    Pathname.glob("#{upgrade_path_for(resource[:source_path])}*.*").each {|f| FileUtils.cp(f.to_s, tmp_dir)}
  end

  def copy_downgrade_scripts_to_tmp
    tmp_dir = Dir.tmpdir
    Pathname.glob("#{downgrade_path_for(resource[:source_path])}*.*").each {|f| FileUtils.cp(f.to_s, tmp_dir)}
  end

  def execute_scripts( scripts)
    FileUtils.cd( resource[:source_path])
    options = self.class.options_for(resource[:schema_name], resource[:password],resource[:database_name])
    options[:parse] = false
    scripts.each do |script|
      Puppet.info "Applying #{script}"
      sql_file(script, options)
      sql yield(script), options
    end
  end


  def scripts_for_upgrade(from, to)
    unloaded_scripts(upgrade_scripts.select {|s| required_for_upgrade?(s, from, to)}.sort!)
  end

  def scripts_for_downgrade(from, to)
    downgrade_scripts.select {|s| required_for_downgrade?(s, from, to)}.sort!.reverse!
  end

  def required_for_upgrade?(script_name, from, to)
    required_for?(script_name,from, to) { |version, from, to| version > from && version <= to}
  end

  def required_for_downgrade?(script_name, from, to)
    required_for?(script_name,from, to) { |version, from, to| version <= from && version > to}
  end

  def required_for?(script_name, from, to)
    _, _, version = parse_script_name(script_name)
    yield(Version.new(version), from, to)
  end

  def parse_script_name(name)
    name.basename.to_s.scan(/^(\d{4}).*_(\D*).*_(\d+.\d+.\d+.*).*_(.*)\.sql$/).flatten
  end

  def unloaded_scripts(scripts)
    scripts.select do | script|
      id, _, _ = parse_script_name(script)
      !is_loaded?(id)
    end
  end

  def upgrade_scripts
    Pathname.glob("#{upgrade_path_for(resource[:source_path])}*.sql").sort
  end

  def downgrade_scripts
    Pathname.glob("#{downgrade_path_for(resource[:source_path])}*.sql").sort
  end

  def is_loaded?(id)
    options = self.class.options_for(resource[:schema_name], resource[:password], resource[:database_name])
    !sql("select * from schema_version where id=#{id}", options).empty?
  end


  def ensure_version_table
    options = self.class.options_for(resource[:schema_name], resource[:password], resource[:database_name])
    create_version_table(options) unless self.class.version_table_exists?(resource, options)
  end

  def create_version_table(options)
    Puppet.info "Creating schema_versions table."
    options[:parse] = false
    statement = template('puppet:///modules/sql_schema_utils/sql_schema_definition/create_table_schema_version.sql.erb', binding)
    sql(statement, options)
  end

  def check_upgrade_path
    fail "source_path #{resource[:source_path]} doesn't contain a upgrades folder" unless File.exists?(upgrade_path_for(resource[:source_path]))
  end

  def check_downgrade_path
    fail "source_path #{resource[:source_path]} doesn't contain a downgrades folder" unless File.exists?(downgrade_path_for(resource[:source_path]))
  end

  def upgrade_path_for(source_path)
    "#{source_path}/upgrades/"
  end

  def downgrade_path_for(source_path)
    "#{source_path}/downgrades/"
  end

end
