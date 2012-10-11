require 'json'
require 'nestful'
require 'commander'
module Tc4r

  class Client
    attr_reader :server
    attr_reader :port
    attr_reader :username
    attr_reader :password
    attr_reader :transport

    def initialize(options = {})
      default_options = { :server   => 'localhost',
                          :port     => 8111,
                          :username => nil,
                          :password => nil,
                          :transport => :http
                        }
      options = default_options.merge(options)

      @server = options[:server]
      @port = options[:port]
      @username = options[:username]
      @password = options[:password]
      @transport = options[:transport]
    end

    def base_url
      @base_url ||= "#{transport}://#{server}:#{port}/httpAuth"
    end

    def rest_url(path)
      "#{base_url}/app/rest/#{path}"
    end

    def download_url(path)
      "#{base_url}/repository/download/#{path}"
    end

    def merge_options(options)
      { :user      => username,
        :password  => password,
        :auth_type => :basic }.merge(options)
    end

    def build_types
      bts = Nestful.get rest_url('buildTypes') , merge_options( :format => :json )
      bts['buildType'].collect do |bt|
        BuildType.new(Tc4r::Helpers.sym_score(bt), self)
      end
    end

    def build_type(bt)
      build_type =  Nestful.get rest_url("buildTypes/id:#{bt}") , merge_options( :format => :json )
      BuildType.new(Tc4r::Helpers.sym_score(build_type), self)
    end

    def query_builds(bt, options = {})
      parameters = {}
      parameters[:status] = 'SUCCESS' if options[:status] == :success
      parameters[:status] = 'ERROR' if options[:status] == :error
      parameters[:tag] = options[:tag] if options[:tag]
      builds = Nestful.get rest_url("buildTypes/id:#{bt}/builds") , merge_options( :format => :json, :params => parameters )
      builds['build'].collect do |build|
        Build.new(Tc4r::Helpers.sym_score(build),self)
      end
    end

    def build(bt,number)
      build = Nestful.get rest_url("buildTypes/id:#{bt}/builds/number:#{number}") , merge_options( :format => :json )
      Tc4r::Build.new(Tc4r::Helpers.sym_score(build), self)
    end

    def download_file(bt,number,file,options = {})
      default_options = {:with_progress => true, :destination => File.expand_path("./#{File.basename(file)}")}
      options = default_options.merge(options)

      download_parameters = {:buffer => true}
      download_parameters[:buffer_binmode] = true
      if options[:with_progress]
        download_parameters[:progress] = progress_bar
      end

      build = build(bt,number)
      f = Nestful.get download_url("#{bt}/#{build.id}:id/#{file}"), merge_options( download_parameters )
      f.close
      FileUtils.mv(f.path,options[:destination])

    end

    def progress_bar
      Proc.new do |conn, total, size| 
        @progress ||= Commander::UI::ProgressBar.new total, :title => "Downloading Build", :complete_message => "File download complete"
        @last_pct ||= 0
        current_pct = ((size.to_f/total.to_f)*100).floor
        @progress.instance_variable_set('@step',size)
        if current_pct != @last_pct
          @progress.show 
          @last_pct = current_pct
        end

        if @progress.finished?
          @progress = nil
        end
      end
    end

  end
end