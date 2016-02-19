module Puppet_X
  module EnterpriseModules
    module Sqlserver
      module TitleParser

        def map_title_to_database(*attributes, &proc)
          all_attributes = [:name] + attributes + [:database_name]
          map_title_to_attributes(*all_attributes, &proc)
        end

      end
    end
  end
end



