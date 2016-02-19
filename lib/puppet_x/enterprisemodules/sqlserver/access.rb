require 'puppet_x/enterprisemodules/powershell'

module Puppet_X
  module EnterpriseModules
    module Sqlserver
      class Access
        include EasyType::Template

        def initialize(database, instance = 'Standard', node = Facter.value('fqdn') )
          @node     = node
          @instance = instance
          @database = database
        end

        def execute(command)
          self.execute(command, @database, @instance, @node)
        end

        def self.execute_file(file_name, database, instance='Standard', node=Facter.value('fqdn'))
          content = template('puppet:///modules/sql_schema_utils/shared/sql_file.ps1.erb', binding)
          Puppet_X::EnterpriseModules::Powershell.execute(content)
        end

        def self.execute(command, database, instance='Standard', node=Facter.value('fqdn'))
          content = template('puppet:///modules/sql_schema_utils/shared/sql_statement.ps1.erb', binding)
          Puppet_X::EnterpriseModules::Powershell.execute(content)
        end

      end
    end
  end
end