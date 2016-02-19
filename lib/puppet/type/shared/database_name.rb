newparam(:database_name) do
  include EasyType

  desc <<-EOD
    Database to connect to.
  EOD

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('database_name')
  end

end
