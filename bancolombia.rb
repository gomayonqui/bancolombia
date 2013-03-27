require "mechanize"
require "yaml"
require 'highline/import'

begin
  puts "checking : config.yml"
  yml = YAML::load(File.open('config.yml'))
  username = yml["username"]
  password = yml["password"]
rescue Exception
  puts "failed to read config: #{$!}"
  username = ask("Enter bancolombia username: ")
  password = ask("Enter bancolombia password: ") { |q| q.echo = "*" }
end

