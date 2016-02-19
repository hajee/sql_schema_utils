newparam(:timeout) do
  include EasyType
  include EasyType::Mungers::Integer

  desc <<-EOD
    Timeout for applying a resource in seconds.

    To be sure no Puppet operation, hangs a Puppet run, all operations have a timeout. When this timeout
    expires, Puppet will abort the current operation and signal an error in the Puppet run.

    With this parameter, you can specify the length of the timeout. The value is specified in seconds. In
    this example, the `timeout`  is set to `600`  seconds.

        ora_type{ ...:
          ...
          timeout => 600,
        }

    The default value for `timeout` is 300 seconds.

  EOD

end
