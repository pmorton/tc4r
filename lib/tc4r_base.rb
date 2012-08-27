require 'tc4r'
require 'terminal-table'

# :name is optional, otherwise uses the basename of this executable
program :name, 'tc4r'
program :version, '1.0.0'
program :description, 'Teamcity Ruby Client'

default_command :useage

command :useage do |c|
  c.syntax = 'tc4r useage'
  c.description = 'Get useage'

  c.action do |args, options|
    
  end
end

def load_config(file)
  if File.exist? File.expand_path(file) 
    return Tc4r::Helpers.symbolize(YAML.load(File.read(File.expand_path(file)))) 
  else
    abort ("Configuration file does not exist #{file}")
  end
end

global_option('-c', '--config FILE', 'Load config data for your commands to use') do |file| 
  $config = load_config(file)
end

unless $config
  $config = load_config('~/.teamcity.yml')
end

command :bt do |c|
  c.syntax = 'tc4r bt'
  c.description = 'List all build types'
  c.option '--format FORMAT', String, 'Output format (TEXT)|JSON'

  c.action do |args, options|
    tc = Tc4r::Client.new($config)
    format = options.format || 'text'
    format = format.downcase.to_sym

    case format
    when :json
      say tc.build_types.to_json
    else
        table = Terminal::Table.new :headings => ['ID','Name','Project'] do |t|
        tc.build_types.each do |build|
          t.add_row [build.id,build.name,build.project_name]
        end
      end
      puts table
    end
  end
end

command :builds do |c|
  c.syntax = 'tc4r builds'
  c.description = 'List all builds for a build type'
  c.option '--bt BUILD_TYPE_ID', String, 'The build type ID to list builds for'
  c.option '--format FORMAT', String, 'Output format (TEXT)|JSON'
  c.option '--status STRING', String, 'Status of the build (BOTH)|ERROR|SUCCESS'

  c.action do |args, options|
    options.default :format => 'text'
    options.default :status => 'both'

    tc = Tc4r::Client.new($config)

    format = options.format.downcase.to_sym

    params = {}

    status = options.status
    status = status.downcase.to_sym

    case status
    when :error
      params[:status] = :error
    when :success
      params[:status] = :success
    end

    case format
    when :json
      say tc.build_type(options.bt).builds.to_json
    else
        table = Terminal::Table.new :headings => ['ID','Number','Status','Start Date'] do |t|
        tc.build_type(options.bt).builds.each do |build|
          t.add_row [build.id,build.number,build.status,build.start_date]
        end
      end
      puts table
    end
  end
end


command :download do |c|
  c.syntax = 'tc4r download'
  c.description = 'Download a file from the build'
  c.option '--bt BUILD_TYPE_ID', String, 'The build type ID to list builds for'
  c.option '--number NUMBER', String, 'The build version number'
  c.option '--file FILE', String, 'The file to download'
  c.option '--dest FILE', String, 'The destination file name'

  c.action do |args, options|
    tc = Tc4r::Client.new($config)
    bt = tc.build_type(options.bt)
    build = bt.build(options.number)
    download_options = {}
    download_options[:destination] = options.dest if options.dest

    tc.download_file(options.bt,options.number,options.file, download_options)
  end
end

