# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
default[:slurm][:version] = "19.05.8-1"
default[:slurm][:user][:name] = 'slurm'
default[:slurm][:cyclecloud_api] = "cyclecloud_api-8.1.0-py2.py3-none-any.whl"
default[:slurm][:autoscale_dir] = "/opt/cycle/slurm"
default[:slurm][:install] = true
default[:slurm][:use_nodename_as_hostname] = false
default[:cyclecloud][:hosts][:simple_vpc_dns][:enabled] = false
default[:cyclecloud][:hosts][:standalone_dns][:enabled] = false
default[:slurm][:additional][:config] = ""
default[:slurm][:ensure_waagent_monitor_hostname] = true

myplatform=node[:platform_family]
case myplatform
  when 'ubuntu', 'debian'
    default[:slurm][:arch] = "amd64"
    default[:slurm][:user][:uid] = 64030
    default[:slurm][:user][:gid] = 64030
  when 'centos', 'rhel', 'redhat', 'almalinux'
    if node[:platform_version] < "8";
      default[:slurm][:arch] = "el7.x86_64"
    else
      default[:slurm][:arch] = "el8.x86_64"
    end
    default[:slurm][:user][:uid] = 11100
    default[:slurm][:user][:gid] = 11100
  when 'suse'
  # does come with the package  
  # slurm:x:468:468:SLURM workload manager:/etc/slurm:/bin/false
    default[:slurm][:user][:uid] = 468
    default[:slurm][:user][:gid] = 468
end

default[:munge][:user][:name] = 'munge'
# does come with the package
# munge:x:467:467:MUNGE authentication service:/run/munge:/usr/sbin/nologin
case myplatform 
  when 'suse'
    default[:munge][:user][:uid] = 467    
    default[:munge][:user][:gid] = 467
  else
    default[:munge][:user][:uid] = 11101
    default[:munge][:user][:gid] = 11101
end
# Time between a suspend call and when that node can be used again - i.e. 10 minutes to shutdown 
default[:slurm][:suspend_timeout] = 600
# Boot timeout
default[:slurm][:resume_timeout] = 1800

default[:slurm][:accounting][:enabled] = false
default[:slurm][:accounting][:user] = 'admin'
default[:slurm][:accounting][:password] = 'admin'
default[:slurm][:accounting][:url] = 'localhost'

default[:slurm][:ha_enabled] = false
