require 'tc4r'
require 'commander/import'

# :name is optional, otherwise uses the basename of this executable
program :name, 'tc4r-setup'
program :version, '1.0.0'
program :description, 'Teamcity Ruby Client Setup Utility'


command :setup do |c|
  c.syntax = 'tc4r bt'
  c.description = 'List all build types'
  c.option '--server SERVER', String, 'Teamcity Server'
  c.option '--port PORT', Integer, 'The port to connect to'
  c.option '--username USERNAME', String, 'Your teamcity username'
  c.option '--password PASSWORD', String, 'Your teamcity password'
  c.option '--transport (HTTP|HTTPS)', String, 'The transport to connect to teamcity'

   c.action do |args, options|
    if File.exist? File.expand_path('~/.teamcity.yml')
      old_config = YAML.load(File.read(File.expand_path('~/.teamcity.yml')))
    else
      old_config = {  'server'    => 'localhost',
                      'port'      => 8111,
                      'transport' => 'http' }
    end

    c = {}
    c['server'] = options.server || ask("Teamcity Server [#{old_config['server']}]: ")
    c['port'] = options.port || ask("Port[#{old_config ['port']}]: ").to_i
    c['transport'] = options.transport || choice = choose("Transport:", 'http', 'https')
    c['username'] = options.username || ask("Username [#{old_config['username']}]: ")
    c['password'] = options.password || ask("Password: ") { |q| q.echo = "*" }

    c.each do |k,v|
      if v.is_a? String and v.empty?
        c[k] = old_config[k]
      elsif v.is_a? Fixnum and v.eql? 0
        c[k] = old_config[k]
      end
    end

    File.open(File.expand_path('~/.teamcity.yml'), "w") {|file| 
      YAML.dump(c,file)
    }
   end

end