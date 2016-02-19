newparam(:schema_name) do
  include EasyType
  include EasyType::Validators::Name
  include EasyType::Mungers::Upcase

  isnamevar

  desc <<-EOD
    The schema name.
  EOD

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('application').upcase
  end


end

