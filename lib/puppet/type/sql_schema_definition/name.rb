newparam(:name) do
  include EasyType
  include EasyType::Validators::Name

  desc <<-EOD
    The schema name.
  EOD

  isnamevar

end

