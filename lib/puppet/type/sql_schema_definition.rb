require 'pathname'
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent)
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent.parent.parent + 'easy_type' + 'lib')
require 'easy_type'
require 'puppet_x/enterprisemodules/sqlserver/access'
require 'puppet_x/enterprisemodules/sqlserver/title_parser'
require 'puppet/type/sql_schema_definition/version'

Puppet::Type.newtype(:sql_schema_definition) do
  include EasyType
  extend Puppet_X::EnterpriseModules::Sqlserver::TitleParser

  desc <<-EOD
    This resource allows you to manage a schema definition. This includes all tables, indexes and other DDL that is needed for your application.
    
        sql_schema_definition{'application_schema@DB1':
          ensure      => '3.3.1',
          source_path => 'c:/staging/'
        }

    EOD

  to_get_raw_resources do
    []
  end

  on_create do | command_builder |
    provider.upgrade_to(self[:ensure])
    nil
  end
  
  on_modify do | command_builder |
    if ::Version.new(self[:ensure]) > provider.ensure
      provider.upgrade_to(self[:ensure])
    else
      provider.downgrade_to(self[:ensure])
    end
    nil
  end

  on_destroy do | command_builder |
    provider.class.destroy(self)
    nil
  end


  map_title_to_database(:schema_name) { /^((.*)@(.*))$/}

  parameter :name
  parameter :schema_name
  parameter :database_name
  parameter :source_path
  parameter :parameters
  parameter :password
  parameter :reinstall
  property  :ensure

end







