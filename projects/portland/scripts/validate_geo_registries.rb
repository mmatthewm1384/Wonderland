#!/usr/bin/env ruby
# PORTLAND GEO registry semantic validator.
# Validates the JSON Schema keyword subset used by the GEO record schemas.

require "yaml"
require "json"
require "uri"
require "set"

ROOT = File.expand_path("..", __dir__)
REGISTRY_DIR = File.join(ROOT, "registries", "geo")
SCHEMA_DIR = File.join(ROOT, "schemas", "geo")

REGISTRIES = {
  "datasets.yaml" => "dataset-record.schema.json",
  "sources-evidence.yaml" => "source-evidence-record.schema.json",
  "boundaries.yaml" => "boundary-record.schema.json"
}.freeze

ERRORS = []

def fail_validation(message)
  ERRORS << message
end

def type_matches?(value, type)
  case type
  when "null"    then value.nil?
  when "string"  then value.is_a?(String)
  when "boolean" then value == true || value == false
  when "integer" then value.is_a?(Integer)
  when "number"  then value.is_a?(Numeric) && !value.is_a?(Complex)
  when "array"   then value.is_a?(Array)
  when "object"  then value.is_a?(Hash)
  else
    false
  end
end

def validate_value(value, definition, path)
  types = definition["type"]

  if types
    types = [types] unless types.is_a?(Array)
    unless types.any? { |type| type_matches?(value, type) }
      fail_validation("#{path}: expected type #{types.inspect}, got #{value.class}")
      return
    end
  end

  if definition.key?("enum") && !definition["enum"].include?(value)
    fail_validation("#{path}: value #{value.inspect} is not in enum #{definition['enum'].inspect}")
  end

  if definition["pattern"] && value.is_a?(String)
    unless Regexp.new(definition["pattern"]).match?(value)
      fail_validation("#{path}: value does not match pattern #{definition['pattern']}")
    end
  end

  if definition["format"] == "uri" && value.is_a?(String)
    begin
      uri = URI.parse(value)
      unless uri.is_a?(URI::HTTP) && uri.host && !uri.host.empty?
        fail_validation("#{path}: expected an absolute HTTP(S) URI")
      end
    rescue URI::InvalidURIError
      fail_validation("#{path}: invalid URI")
    end
  end

  if definition["items"] && value.is_a?(Array)
    value.each_with_index do |item, index|
      validate_value(item, definition["items"], "#{path}[#{index}]")
    end
  end
end

def validate_record(record, schema, registry_name, index)
  path = "#{registry_name}.records[#{index}]"

  unless record.is_a?(Hash)
    fail_validation("#{path}: expected a mapping/object")
    return
  end

  required = schema.fetch("required", [])
  properties = schema.fetch("properties", {})

  (required - record.keys).each do |field|
    fail_validation("#{path}: missing required property '#{field}'")
  end

  if schema["additionalProperties"] == false
    (record.keys - properties.keys).each do |field|
      fail_validation("#{path}: undeclared property '#{field}'")
    end
  end

  record.each do |field, value|
    definition = properties[field]
    next unless definition

    validate_value(value, definition, "#{path}.#{field}")
  end
end

def load_yaml(path)
  YAML.safe_load(
    File.read(path),
    permitted_classes: [],
    permitted_symbols: [],
    aliases: false
  )
end

records_by_file = {}
schemas_by_file = {}

REGISTRIES.each do |registry_file, schema_file|
  registry_path = File.join(REGISTRY_DIR, registry_file)
  schema_path = File.join(SCHEMA_DIR, schema_file)

  registry = load_yaml(registry_path)
  schema = JSON.parse(File.read(schema_path))

  unless registry.is_a?(Hash) &&
         registry["registry"].is_a?(Hash) &&
         registry["registry"]["records"].is_a?(Array)
    fail_validation("#{registry_file}: invalid registry envelope")
    next
  end

  records = registry["registry"]["records"]
  records_by_file[registry_file] = records
  schemas_by_file[registry_file] = schema

  records.each_with_index do |record, index|
    validate_record(record, schema, registry_file, index)
  end

  ids = records.filter_map do |record|
    record["local_id"] if record.is_a?(Hash)
  end

  if ids.uniq.length != ids.length
    fail_validation("#{registry_file}: duplicate local identifiers")
  end

  puts "CHECKED: #{registry_file} (#{records.length} records)"
  puts "CHECKED: #{schema_file}"
end

# Cross-registry dataset reference validation.
dataset_records = records_by_file.fetch("datasets.yaml", [])
dataset_ids = dataset_records.filter_map do |record|
  record["local_id"] if record.is_a?(Hash)
end.to_set

records_by_file.fetch("sources-evidence.yaml", []).each do |record|
  next unless record.is_a?(Hash)

  refs = record["dataset_refs"]
  next unless refs.is_a?(Array)

  refs.each do |ref|
    unless dataset_ids.include?(ref)
      fail_validation("#{record['local_id']}: unresolved dataset reference #{ref.inspect}")
    end
  end
end

# Ensure local registry identifiers follow their expected namespaces.
{
  "datasets.yaml" => /\AGDS-[0-9]{3,}\z/,
  "sources-evidence.yaml" => /\AGEV-[0-9]{3,}\z/,
  "boundaries.yaml" => /\AGBD-[0-9]{3,}\z/
}.each do |file, pattern|
  records_by_file.fetch(file, []).each do |record|
    next unless record.is_a?(Hash)

    id = record["local_id"]
    if id && !pattern.match?(id)
      fail_validation("#{file}: invalid local identifier #{id.inspect}")
    end
  end
end

puts
puts "===== SEMANTIC VALIDATION ====="

if ERRORS.empty?
  puts "PASS: schema-subset validation"
  puts "PASS: local identifier namespaces"
  puts "PASS: unique identifiers within registries"
  puts "PASS: source-to-dataset references"
  puts
  puts "===== RECORD COUNTS ====="
  records_by_file.each do |file, records|
    puts "#{file}: #{records.length}"
  end
  puts
  puts "RESULT: PASS"
else
  ERRORS.each { |error| warn "FAIL: #{error}" }
  warn
  warn "RESULT: FAIL (#{ERRORS.length} issue(s))"
  exit 1
end
