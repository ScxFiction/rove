module Hospice
  class Pattern
    include Support::Storer

    attr_reader :name, :packages, :configuration

    def initialize(name, &block)
      @name = name
      @packages = {}
      store
      instance_eval &block if block_given?
      build_configuration!
    end

    def package(name, options = {})
      @packages[name] = options
    end

    def self.find(name)
      all.find{|pattern| pattern.name.to_s.downcase == name.to_s.downcase}
    end

    private

    def build_configuration!
      @configuration = {}
      @packages.each_pair do |key, value|
        @configuration[key] = convert_options(value, key)
      end
    end


    def concat(prefix, value)
      "#{prefix}-#{value}"
    end

    def convert_options(value, prefix = "")
      res = []
      if value.is_a?(Hash)
        value.each_pair do |key, values|
          res << concat(prefix,key)
          res << convert_options(values, concat(prefix,key))
        end
      elsif value.is_a?(Array)
        value.each{|i| res << convert_options(i, prefix)}
      else
        res << concat(prefix, value)
      end
      res.flatten
    end
  end
end