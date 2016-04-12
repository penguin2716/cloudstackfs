#!/usr/bin/env ruby

require 'rfusefs'
require File.expand_path(File.join(File.dirname(__FILE__), 'lib', 'api_caller'))

class CloudStackDir

  def initialize
    @actions = ["deploy", "destroy", "reboot", "start", "stop"]
    refresh
  end

  def refresh
    @apic = APICaller.new
    @zones = @apic.listZones.zone
    @templates = @apic.listTemplates(templatefilter: "executable").template
    @serviceofferings = @apic.listServiceOfferings.serviceoffering
    @vms = @apic.listVirtualMachines.virtualmachine
  end

  def contents(path)
    zone, template, serviceoffering, vm, detail1, detail2 = path.sub(/^\//, "").split("/")

    if detail2
      ["nic", "securitygroup"].include?(detail1) ?
        @vms.detect{|v| v.name == vm}[detail1].detect{|item| item.id == detail2}.keys : []
    elsif detail1
      ["nic", "securitygroup"].include?(detail1) ?
        @vms.detect{|v| v.name == vm}[detail1].map(&:id) : []
    elsif vm
      @vms.detect{|v| v.name == vm}.keys
    elsif serviceoffering
      @vms.select{|v| v.zonename == zone}.select{|v| v.templatename == template}.select{|v| v.serviceofferingname == serviceoffering}.map(&:name) + @actions
    elsif template
      @serviceofferings.map(&:name)
    elsif zone
      @templates.select{|t| t.zonename == zone}.map(&:name)
    else
      @zones.map(&:name)
    end

  end

  def directory?(path)
    zone, template, serviceoffering, vm, detail1, detail2, detail3 = path.sub(/^\//, "").split("/")
    
    if detail3
      false
    elsif detail2
      ["nic", "securitygroup"].include?(detail1)
    elsif detail1
      ["nic", "securitygroup"].include?(detail1)
    elsif vm
      @vms.map(&:name).include?(vm)
    elsif serviceoffering
      @serviceofferings.map(&:name).include?(serviceoffering)
    elsif template
      @templates.map(&:name).include?(template)
    elsif zone
      @zones.map(&:name).include?(zone)
    else
      false
    end

  end
  
  def file?(path)
    zone, template, serviceoffering, vm, detail1, detail2, detail3 = path.sub(/^\//, "").split("/")

    return false if directory?(path)
    return true if @actions.include?(vm)

    if detail3
      @vms.detect{|v| v.name == vm}[detail1].detect{|item| item.id == detail2}[detail3]
    elsif detail1
      @vms.detect{|v| v.name == vm}[detail1]
    end

  end

  def read_file(path)
    zone, template, serviceoffering, vm, detail1, detail2, detail3 = path.sub(/^\//, "").split("/")
    if detail3
      @vms.detect{|v| v.name == vm}[detail1].detect{|item| item.id == detail2}[detail3]
    elsif detail1
      @vms.detect{|v| v.name == vm}[detail1]
    elsif @actions.include?(vm)
      "write vm name here"
    end
  end

  def can_write?(path)
    zone, template, serviceoffering, vm, detail1, detail2, detail3 = path.sub(/^\//, "").split("/")
    @actions.include?(vm)
  end

  def write_to(path, str)
    zone, template, serviceoffering, vm, detail1, detail2, detail3 = path.sub(/^\//, "").split("/")

    case File.basename(path)
    when "deploy"
      unless @vms.detect{|v| v.name == vm}
        soid = @serviceofferings.detect{|o| o.name == serviceoffering}.id
        zid = @zones.detect{|z| z.name == zone}.id
        tid = @templates.detect{|t| t.name == template}.id
        @apic.deployVirtualMachine(serviceofferingid: soid, templateid: tid, zoneid: zid, name: str.chomp)
      end
    when "destroy"
      @apic.destroyVirtualMachine(id: @vms.detect{|v| v.name == str.chomp}.id) if @vms.detect{|v| v.name == str.chomp}
    when "reboot"
      @apic.rebootVirtualMachine(id: @vms.detect{|v| v.name == str.chomp}.id) if @vms.detect{|v| v.name == str.chomp}
    when "start"
      @apic.startVirtualMachine(id: @vms.detect{|v| v.name == str.chomp}.id) if @vms.detect{|v| v.name == str.chomp}
    when "stop"
      @apic.stopVirtualMachine(id: @vms.detect{|v| v.name == str.chomp}.id) if @vms.detect{|v| v.name == str.chomp}
    end
    refresh
  end

  def touch(path, modtime)
    refresh
  end

end

# Usage: #{$0} mountpoint [mount_options]
FuseFS.main() { |options|
  Process.daemon(true)
  CloudStackDir.new
}
