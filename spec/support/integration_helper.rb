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
    fsi = Vcloud::Fog::ServiceInterface.new()
    vapp_list.each do |vapp|
      if Integer(vapp.vcloud_attributes[:status]) == Vcloud::Core::Vapp::STATUS::RUNNING
        fsi.post_undeploy_vapp(vapp.id)
      end
      fsi.delete_vapp(vapp.id)
    end
  end

  def self.ensure_networks_correct(test_params)
    vcloud = ::Fog::Compute::VcloudDirector.new
    org = vcloud.organizations.get_by_name(vcloud.org_name)
    interfaces = org.networks.all(false)

    network_config = {
      :network_1 => {
        :is_shared    => 'true',
        :name         => test_params["network_1"],
        :vdc_name     => test_params["vdc_1_name"],
        :fence_mode   => 'natRouted',
        :netmask      => '255.255.255.0',
        :gateway      => '192.168.1.1',
        :edge_gateway => test_params["edge_gateway"],
        :ip_ranges    => [
          {
            :start_address  => "192.168.1.2",
            :end_address    => "192.168.1.254"
          }
        ],
      },
      :network_2 => {
        :is_shared    => 'true',
        :name         => test_params["network_2"],
        :vdc_name     => test_params["vdc_2_name"],
        :fence_mode   => 'isolated',
        :netmask      => '255.255.0.0',
        :gateway      => '10.0.0.1',
        :edge_gateway => test_params["edge_gateway"],
        :ip_ranges    => [
          {
            :start_address  => "10.0.0.2",
            :end_address    => "10.0.255.254"
          }
        ],
      },
    }

    %w(network_1 network_2).each do |test_network|
      found_network = interfaces.detect { |i| i.name == test_params[test_network] }
      expected_config = network_config[:"#{test_network}"]

      if found_network
        test_params[test_network + "_id"] = found_network.id
      else
        new_network = Vcloud::Core::OrgVdcNetwork.provision(expected_config)
        test_params[test_network + "_id"] = new_network.id
        next
      end

      expected_ip_range = expected_config[:ip_ranges][0]

      fence_mode = (found_network.fence_mode == expected_config[:fence_mode])
      ip_range = found_network.ip_ranges.detect do |r|
        r[:start_address] == expected_ip_range[:start_address]
      end

      ip_range   = (ip_range && ip_range[:end_address] == expected_ip_range[:end_address])
      gateway    = (found_network.gateway    == expected_config[:gateway])
      netmask    = (found_network.netmask    == expected_config[:netmask])
      is_shared  = (found_network.is_shared  == expected_config[:is_shared])

      unless fence_mode && gateway && netmask && ip_range && is_shared
        raise "Network '#{test_params[test_network]}' already exists but is not configured as expected.
          You should delete this network before re-running the tests; it will be re-created by the tests."
      end
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
