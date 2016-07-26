require 'aws-sdk'
require 'json'
require 'pp'

ROOT = File.expand_path('..')

class Resource
  require_relative 'resource/iam'
  require_relative 'resource/diff'
  require_relative 'resource/lambda'
  require_relative 'resource/kinesis'
  require_relative 'resource/properties'
  require_relative 'resource/exceptions'

  def initialize(desired_hash)
    @desired_properties = Properties.new(self.class, desired_hash)
    @wait_attempts = 20
    @wait_time = 0.5
  end

  def create
    raise MissingProperties if not @desired_properties.valid?(:create)
    raise ResourceAlreadyExists if @desired_properties.valid?(:key) && exists?
    create_resource 
    output(properties?)
    properties?
  end

  def delete
    raise MissingProperties if not @desired_properties.valid?(:key)
    @current_properties = properties?
    delete_resource 
  end

  def modify
    raise MissingProperties if not @desired_properties.valid?(:key)
    @current_properties = properties?
    raise ResourceDoesNotExist if @current_properties == nil

    diff = get_diff(@current_properties, @desired_properties)
    process_diff(diff)
    # wait_for_modify
    output(properties?)
    properties?
  end

  private

  def wait_for_modify
    (0...@wait_attempts).each do
      @current_properties = properties?
      diff = get_diff(@current_properties, @desired_properties)
      return if diff == {}
      pp 'Waiting on: ' + diff.to_s
      sleep(@wait_time)
    end
    raise Resource::ResourceTookToLong
  end

  def get_diff(current, desired)
    diff = Diff.new
    @desired_properties.keys.each do |key|
      next unless current[key] != desired[key]
      diff[key] = desired[key]
    end
    diff.delete(:region)
    format_diff!(diff)
    diff
  end

  def output(properties)
    json = properties.to_json
    File.open('output.json', 'w') { |file| file.write(json) }
    json
  end

  def exists?
    raise MissingProperties if not @desired_properties.valid?(:key)
    properties? != nil
  end

  def keys(tag)
    return METADATA.keys if tag.nil?
    self.class::METADATA.keys.select { |key| self.class::METADATA[key].include?(tag) }
  end

  def properties?
    raw_props = raw_properties
    return nil if raw_props.nil?
    parse_properties(raw_props)
  end

  def parse_properties(raw_props)
    Resource::Properties.new(self.class, raw_props)
  end

  def format_diff!(diff)
    diff
  end

  def raw_properties
    raise Unimplemented
  end

  def create_resource
    raise Unimplemented
  end

  def delete_resource
    raise Unimplemented
  end

  def process_diff(diff)
    raise Unimplemented
  end
end
