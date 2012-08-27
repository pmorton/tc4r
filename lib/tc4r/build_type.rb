module Tc4r
  class BuildType
    include ActiveModel::Serializers::JSON
    self.include_root_in_json = false

    attr_reader :id,:name,:project_name,:project_id, :href, :client

    def initialize(options = {},client)
      options = Tc4r::Helpers.symbolize(options)
      @id = options[:id]
      @name = options[:name]
      @project_name = options[:project_name] || options[:project][:name]
      @project_id = options[:project_id] || options[:project][:id]
      @href = options[:href] 
      @client = client
    end

    def attributes
      { :id => @id, :name => @name, :project_name => @project_name, :project_id => @project_id, :href => @href }
    end

    def builds
      client.query_builds(id)
    end

    def build(number)
      client.build(id,number)
    end


  end
end