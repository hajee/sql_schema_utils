require 'puppet_x/enterprisemodules/powershell'
require 'easy_type'

module Puppet_X
  module EnterpriseModules
    module Sqlserver
      module Sql
        include EasyType::Helpers

        def self.included( parent)
          parent.extend(self)
        end

        def sql_file(file, options)
          csv_string = Access.execute_file(file, options[:database_name])[:stdout]
          if options.fetch(:parse) { true }
            csv_string.empty? ? [] : convert_csv_data_to_hash(csv_string).collect{|e| e.merge('database_name' => options[:database_name])}
          end
        end


        def sql(statement, options)
          csv_string = Access.execute(statement, options[:database_name])[:stdout]
          if options.fetch(:parse) { true }
            csv_string.empty? ? [] : convert_csv_data_to_hash(csv_string).collect{|e| e.merge('database_name' => options[:database_name])}
          end
        end
      end
    end
  end
end