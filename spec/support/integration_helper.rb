module IntegrationHelper

  def self.create_test_case_vapps(number_of_vapps,
                                  vdc_name,
                                  catalog_name,
                                  vapp_template_name,
                                  network_names = [],
                                  prefix = "vcloud-core-tests"
                                 )
    vapp_template = Vcloud::Core::VappTemplate.get(vapp_template_name, catalog_name)
    timestamp_in_s = Time.new.to_i
    base_vapp_name = "#{prefix}-#{timestamp_in_s}-"
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
    fsi = Vcloud::Core::Fog::ServiceInterface.new()
    vapp_list.each do |vapp|
      if Integer(vapp.vcloud_attributes[:status]) == Vcloud::Core::Vapp::STATUS::RUNNING
        fsi.post_undeploy_vapp(vapp.id)
      end
      fsi.delete_vapp(vapp.id)
    end
  end

  def self.create_test_case_independent_disks(number_of_disks,
                                  vdc_name,
                                  size,
                                  prefix = "vcloud-core-tests"
                                 )
    timestamp_in_s = Time.new.to_i
    base_disk_name = "#{prefix}-#{timestamp_in_s}-"
    disk_list = []
    vdc = Vcloud::Core::Vdc.get_by_name(vdc_name)
    number_of_disks.times do |index|
      disk_list << Vcloud::Core::IndependentDisk.create(
        vdc,
        base_disk_name + index.to_s,
        size,
      )
    end
    disk_list
  end

  def self.delete_independent_disks(disk_list)
    fsi = Vcloud::Core::Fog::ServiceInterface.new()
    disk_list.each do |disk|
      fsi.delete_disk(disk.id)
    end
  end

  def self.reset_edge_gateway(edge_gateway)
    configuration = {
        :FirewallService =>
            {
                :IsEnabled        => "false",
                :FirewallRule     => [],
                :DefaultAction    => "drop",
                :LogDefaultAction => "false",
            },
        :LoadBalancerService =>
            {
                :IsEnabled      => "false",
                :Pool           => [],
                :VirtualServer  => [],
            },
        :NatService =>
            {
                :IsEnabled  => "false",
                :NatRule    => [],
            },
    }

    edge_gateway.update_configuration(configuration)
  end
end
