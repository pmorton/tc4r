module Tc4r
  class Build
    include ActiveModel::Serializers::JSON
    self.include_root_in_json = false

    attr_reader :id, :number, :status, :build_type_id, :start_date, :href, :client
    def initialize(options,client)
      options = Tc4r::Helpers.symbolize(options)
      @id = options[:id]
      @number = options[:number]
      @status = options[:status]
      @build_type_id = options[:build_type_id]
      @start_date = Time.parse(options[:start_date])
      @href = options[:href]
      @client = client
    end

    def attributes
      { :id => @id, :number => @number, :status => @status, :build_type_id => @build_type_id, :start_date => @start_date, :href => @href }
    end

    def download_file(file, options = {})
      client.download_file(build_type_id,number,file,options)
    end

  end
end