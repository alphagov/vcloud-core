require 'fog'
require 'vcloud/core/fog/fog_constants'
require 'vcloud/core/fog/login'
require 'vcloud/core/fog/service_interface'
require 'vcloud/core/fog/model_interface'

module Vcloud
  module Core
    module Fog
      TOKEN_ENV_VAR_NAME = 'FOG_VCLOUD_TOKEN'
      FOG_CREDS_PASS_NAME = :vcloud_director_password

      # Logout an existing vCloud session, rendering the token unusable.
      # Requires a FOG_VCLOUD_TOKEN environment variable to be set.
      #
      # @return [Boolean] return true or raise an exception
      def self.logout
        unless ENV[TOKEN_ENV_VAR_NAME]
          raise "#{TOKEN_ENV_VAR_NAME} environment variable is not set"
        end

        fsi = Vcloud::Core::Fog::ServiceInterface.new
        fsi.logout

        return true
      end

      # Run any checks needed against the Fog credentials
      # currently only used to disallow plaintext passwords
      # in .fog files.
      #
      def self.check_credentials
        pass = fog_credentials_pass
        unless pass.nil? or pass.empty?
          warn <<EOF
[WARNING] Storing :vcloud_director_password in your plaintext FOG_RC file is
          insecure. Future releases of vcloud-core (and tools that depend on
          it) will prevent you from doing this. Please use vcloud-login to
          get a session token instead.
EOF
        end
      end

      # Attempt to load the password from the fog credentials file
      #
      # @return [String, nil] The password if it could be loaded, 
      #                       else nil.
      def self.fog_credentials_pass
        begin
          pass = ::Fog.credentials[FOG_CREDS_PASS_NAME]
        rescue ::Fog::Errors::LoadError
          # Assume no password if Fog has been unable to load creds.
          # Suppresses a noisy error about missing credentials.
          pass = nil
        end

        pass
      end
    end
  end
end

Vcloud::Core::Fog.check_credentials
