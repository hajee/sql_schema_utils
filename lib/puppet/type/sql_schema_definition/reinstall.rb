newparam(:reinstall) do

  desc <<-EOD
    Force delete before applying the schema updates.
  EOD

  newvalues(:true, :false)

  defaultto(:false)

end

