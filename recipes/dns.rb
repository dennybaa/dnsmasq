include_recipe 'dnsmasq::default'
include_recipe 'dnsmasq::manage_hostsfile'

dns_config = node[:dnsmasq][:dns].to_hash
unless(node[:dnsmasq][:enable_dhcp])
  dns_config['no-dhcp-interface='] = nil
end

# Check resolvconf usage
unless %x(which resolvconf).empty? || ::File.exist?('/etc/dnsmasq.d/dns.conf')
  service 'dnsmasq' do
    Chef::Log.error("resolvconf package is used but /etc/dnsmasq.d/dns.conf not found, resolving is not possible.")
    action [:stop]
  end
end


template '/etc/dnsmasq.d/dns.conf' do
  source 'dynamic_config.erb'
  mode 0644
  variables(
    :config => dns_config,
    :list => node['dnsmasq']['dns_options']
  )
  notifies :restart, "service[dnsmasq]"
end
