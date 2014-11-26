require 'fog'

module Vcloud
  module Core
    module Fog
      module Login
        class << self
          def token(pass)
            Vcloud::Core::Fog.check_credentials
            token = get_token(pass)

            return token
          end

          def token_export(*args)
            key   = Vcloud::Core::Fog::TOKEN_ENV_VAR_NAME
            value = token(*args)

            return case `ps -p $$ -o ucomm=`
                     when 'fish'
                       "set -x #{key} #{value}"
                     else
                       "export #{key}=#{value}"
                   end
          end

          private

          def get_token(pass)
            ENV.delete(Vcloud::Core::Fog::TOKEN_ENV_VAR_NAME)
            vcloud = ::Fog::Compute::VcloudDirector.new({
              Vcloud::Core::Fog::FOG_CREDS_PASS_NAME => pass,
            })

            return vcloud.vcloud_token
          end
        end
      end
    end
  end
end
