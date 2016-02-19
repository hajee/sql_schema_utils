require 'puppet_x/puppetlabs/powershell_manager' if Puppet::Util::Platform.windows?

module Puppet_X
  module EnterpriseModules
    class Powershell

      def initialize
        @shell = self.get_shell
      end

      def execute(command)
        @shell.execute(command)
      end

      def self.execute(command)
        @shell ||= get_shell
        @shell.execute(command)
      end

      private

      #
      # Get a Powershell daemon handler
      #
      def self.get_shell
        command ||= Puppet::Type.type(:base_dsc).defaultprovider.command(:powershell)
        powershell_args = Puppet::Type.type(:base_dsc).defaultprovider.powershell_args
        PuppetX::Dsc::PowerShellManager.instance("#{command} #{powershell_args.join(' ')}")
      end

    end
  end
end


