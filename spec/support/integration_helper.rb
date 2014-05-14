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

  def self.create_test_case_vapps(number_of_vapps,
                                  vdc_name,
                                  catalog_name,
                                  vapp_template_name,
                                  network_names = [],
                                  prefix = "vcloud-core-tests-"
                                 )
    vapp_template = Vcloud::Core::VappTemplate.get(catalog_name, vapp_template_name)
    timestamp_in_s = Time.new.to_i
    base_vapp_name = "#{prefix}#{timestamp_in_s}-"
    vapp_list = []
    number_of_vapps.times do |index|
      vapp_list << Vcloud::Core::Vapp.instantiate(
        base_vapp_name + index.to_s,
        network_names,
        vapp_template.id,
        vdc_name
      )
    end
    vapp_list
  end

  def self.delete_vapps(vapp_list)
    fsi = Vcloud::Fog::ServiceInterface.new()
    vapp_list.each do |vapp|
      fsi.delete_vapp(vapp.id)
    end
  end

end
