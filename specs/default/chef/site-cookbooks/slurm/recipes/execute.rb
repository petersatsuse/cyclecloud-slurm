#
# Cookbook Name:: slurm
# Recipe:: execute
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
nodename = node[:cyclecloud][:node][:name]

if node[:slurm][:use_nodename_as_hostname] then
  execute 'set hostname' do
    command "hostname #{nodename}"
    creates '/etc/slurm.hostname.#{nodename}.enabled'
  end
end

include_recipe "slurm::default"
require 'chef/mixin/shell_out'

slurmuser = node[:slurm][:user][:name]

remote_file '/etc/munge/munge.key' do
  source 'file:///sched/munge/munge.key'
  owner 'munge'
  group 'munge'
  mode '0700'
  action :create
end

link '/etc/slurm/slurm.conf' do
  to '/sched/slurm.conf'
  owner "#{slurmuser}"
  group "#{slurmuser}"
end

link '/etc/slurm/cyclecloud.conf' do
  to '/sched/cyclecloud.conf'
  owner "#{slurmuser}"
  group "#{slurmuser}"
end

link '/etc/slurm/cgroup.conf' do
  to '/sched/cgroup.conf'
  owner "#{slurmuser}"
  group "#{slurmuser}"
end

link '/etc/slurm/topology.conf' do
  to '/sched/topology.conf'
  owner "#{slurmuser}"
  group "#{slurmuser}"
end

link '/etc/slurm/gres.conf' do
  to '/sched/gres.conf'
  owner "#{slurmuser}"
  group "#{slurmuser}"
  only_if { ::File.exist?('/sched/gres.conf') }
end


defer_block "Defer starting slurmd until end of converge" do
  slurmd_sysconfig="SLURMD_OPTIONS=-N #{nodename}"

  myplatform=node[:platform]
  case myplatform
  when 'ubuntu'
    directory '/etc/sysconfig' do
      action :create
    end
    
    file '/etc/sysconfig/slurmd' do
      content slurmd_sysconfig
      mode '0700'
      owner 'slurm'
      group 'slurm'
    end
  when 'centos', 'rhel', 'redhat'
    file '/etc/sysconfig/slurmd' do
      content slurmd_sysconfig
      mode '0700'
      owner 'slurm'
      group 'slurm'
    end
  end

  service 'slurmd' do
    action [:enable, :start]
  end

  service 'munge' do
    action [:enable, :restart]
  end

  # Re-enable a host the first time it converges in the event it was drained
  # set the ip as nodeaddr and hostname in slurm
  execute 'set node to active' do
    # no longer set hostname/nodeaddr. cyclecloud_slurm.py on the slurmctld host will do this.
    command "scontrol update nodename=#{nodename} state=UNDRAIN && touch /etc/slurm.reenabled"
    creates '/etc/slurm.reenabled'
  end
end
