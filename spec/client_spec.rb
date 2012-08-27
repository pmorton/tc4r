require_relative 'spec_helper.rb'

describe Tc4r::Client do
  let(:client) { Tc4r::Client.new( :username => 'username', :password => 'password') }

  it 'should initialize and setup attr_readers' do
    client = Tc4r::Client.new(:server   => 'notlocalhost',
                          :port     => 8112,
                          :username => 'username',
                          :password => 'password',
                          :transport => :https)
    client.server.should == 'notlocalhost'
    client.port.should == 8112
    client.password.should == 'password'
    client.transport.should == :https
  end 

  it 'should merge options into defaults' do
    client = Tc4r::Client.new( :port     => 8112,
                          :username => 'username',
                          :password => 'password') 
    client.port.should == 8112
    client.server.should == 'localhost'
    client.username.should == 'username'
    client.password.should == 'password'
    client.transport.should == :http
  end

  it 'should generate urls' do
    client = Tc4r::Client.new()
    client.base_url.should == 'http://localhost:8111/httpAuth'
    client.rest_url('some_endpoint').should == 'http://localhost:8111/httpAuth/app/rest/some_endpoint'
    client.download_url('some_endpoint').should == 'http://localhost:8111/httpAuth/repository/download/some_endpoint'
  end

  it 'should merge global parameters' do
    options = client.merge_options(:test_parameter => 'test')
    options[:test_parameter].should == 'test'
    options[:user].should == 'username'
    options[:password].should == 'password'
    options[:auth_type].should == :basic
  end

  it 'should query for successful builds for a build type' do
    FakeWeb.register_uri(:get, "http://username:password@localhost:8111/httpAuth/app/rest/buildTypes/id:bt1/builds?status=SUCCESS", :body => File.read('spec/requests/builds_bt1.json'), :content_type => "application/json")
    build_types = client.query_builds 'bt1', :status => :success
    FakeWeb.should have_requested(:get, 'http://username:password@localhost:8111/httpAuth/app/rest/buildTypes/id:bt1/builds?status=SUCCESS')
    build_types.each do |b|
      b.should be_a_kind_of Tc4r::Build
    end
  end

  it 'should query for errored builds for a build type' do
    FakeWeb.register_uri(:get, "http://username:password@localhost:8111/httpAuth/app/rest/buildTypes/id:bt1/builds?status=ERROR", :body => File.read('spec/requests/builds_bt1.json'), :content_type => "application/json")
    build_types = client.query_builds 'bt1', :status => :error
    FakeWeb.should have_requested(:get, 'http://username:password@localhost:8111/httpAuth/app/rest/buildTypes/id:bt1/builds?status=ERROR')
    build_types.each do |b|
      b.should be_a_kind_of Tc4r::Build
    end
  end


  it 'should query build types' do
    FakeWeb.register_uri(:get, "http://username:password@localhost:8111/httpAuth/app/rest/buildTypes", :body => File.read('spec/requests/build_types.json'), :content_type => "application/json")
    build_types = client.build_types  
    FakeWeb.should have_requested(:get, "http://username:password@localhost:8111/httpAuth/app/rest/buildTypes")
    build_types.each do |bt|
      bt.should be_a_kind_of Tc4r::BuildType
    end
  end

  it 'should query builds for a build type' do
    FakeWeb.register_uri(:get, "http://username:password@localhost:8111/httpAuth/app/rest/buildTypes/id:bt1/builds", :body => File.read('spec/requests/builds_bt1.json'), :content_type => "application/json")
    build_types = client.query_builds 'bt1'
    FakeWeb.should have_requested(:get, "http://username:password@localhost:8111/httpAuth/app/rest/buildTypes/id:bt1/builds")
    build_types.each do |b|
      b.should be_a_kind_of Tc4r::Build
    end 
  end

  it 'should get a specific build number' do
    FakeWeb.register_uri(:get, "http://username:password@localhost:8111/httpAuth/app/rest/buildTypes/id:bt1/builds/number:3.0.85", :body => File.read('spec/requests/build_5733.json'), :content_type => "application/json")  
    build = client.build 'bt1', '3.0.85'
    FakeWeb.should have_requested(:get, "http://username:password@localhost:8111/httpAuth/app/rest/buildTypes/id:bt1/builds/number:3.0.85")
    build.should be_a_kind_of Tc4r::Build
  end

  it 'should download a build to a specific destination' do
    FakeWeb.register_uri(:get, "http://username:password@localhost:8111/httpAuth/app/rest/buildTypes/id:bt1/builds/number:3.0.85", :body => File.read('spec/requests/build_5733.json'), :content_type => "application/json")
    FakeWeb.register_uri(:get, "http://username:password@localhost:8111/httpAuth/repository/download/bt1/5733:id/test.zip", :body => {}.to_json, :content_length => 1234 )  
    FileUtils.stub(:mv) {}
    FileUtils.should_receive(:mv).with(kind_of(String),'/tmp/test.zip')
    client.download_file 'bt1', '3.0.85', 'test.zip', {:destination => '/tmp/test.zip'}
  end

  it 'should download a build to a my working directory' do
    FakeWeb.register_uri(:get, "http://username:password@localhost:8111/httpAuth/app/rest/buildTypes/id:bt1/builds/number:3.0.85", :body => File.read('spec/requests/build_5733.json'), :content_type => "application/json")
    FakeWeb.register_uri(:get, "http://username:password@localhost:8111/httpAuth/repository/download/bt1/5733:id/test.zip", :body => {}.to_json, :content_length => 1234 )  
    FileUtils.stub(:mv) {}
    FileUtils.should_receive(:mv).with(kind_of(String),File.expand_path('./test.zip'))
    client.download_file 'bt1', '3.0.85', 'test.zip'
  end


end