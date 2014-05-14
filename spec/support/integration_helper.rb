module IntegrationHelper

  REQUIRED_ENV = {
    'VCLOUD_VDC_NAME' =>
      'to the name of an orgVdc to use to instantiate vApps into',
    'VCLOUD_TEMPLATE_NAME' =>
      'to the name of a vAppTemplate to use create vApps in tests',
    'VCLOUD_CATALOG_NAME' =>
      'to the name of the catalog that VCLOUD_VAPP_TEMPLATE_NAME is stored in',
    'VCLOUD_NETWORK1_NAME' =>
       'to the name of an OrgVdcNetwork in VCLOUD_VDC_NAME',
    'VCLOUD_NETWORK2_NAME' =>
       'to the name of an OrgVdcNetwork in VCLOUD_VDC_NAME',
  }

  def self.verify_env_vars
    error = false
    REQUIRED_ENV.each do |var,message|
      unless ENV[var]
        puts "Must set #{var} #{message}" unless ENV[var]
        error = true
      end
    end
    Kernel.exit(2) if error
  end

end
