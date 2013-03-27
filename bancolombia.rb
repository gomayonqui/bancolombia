require "mechanize"
require "yaml"
require 'highline/import'

begin
  puts "Config file detected"
  yml = YAML::load(File.open('config.yml'))
  username = yml["username"]
  password = yml["password"]
rescue Exception
  puts "No config file to read."
  username = ask("Enter your bancolombia username: ")
  password = ask("Enter your 4 digits bancolombia password: ") { |q| q.echo = "*" }
end

##Login username page
agent = Mechanize.new
agent.get("https://bancolombia.olb.todo1.com/olb/Init")
userLoginPage = agent.get("https://bancolombia.olb.todo1.com/olb/Login")
userLoginPage.form_with(:name => "authenticationForm") do |f|
  f.userId = username
end.click_button

##Redirect to password page
passwordPage = agent.get("https://bancolombia.olb.todo1.com/olb/GetUserProfile")
passwordPageHtml = passwordPage.body
##Insert \r for correct regex on password scripts
passwordPageHtml.gsub!(/document.getElementById/, "\r\n\t document.getElementById")
enc_password = ""
password.to_s.split('').each do |n|
  passwordPageHtml.match(/\'td_#{n}\'\)\.addEventListener\(\'click\'\,\sfunction\(\)\{\S*\(\"(.*)\"\)\;\}/);
  enc_password << $1
end
##Capture secret hidden field
passwordPageHtml.match(/'PASSWORD\':\'(.*)\'/)
secretHiddenField = $1

##Post encripted password and secret hidden field
passwordPage.form_with(:name => "authenticationForm") do |f|
  f.userId = "0"
  f.password = enc_password
  f.add_field!(secretHiddenField, value = enc_password)
end.click_button

##Get Balance
agent.get("https://bancolombia.olb.todo1.com/olb/Authentication")
balancePage = agent.get("/olb/BeginInitializeActionFromCM?from=pageTabs")
balance = balancePage.search(".contentTotalNegrita").last.children.text
puts "Your actual balance is: $#{balance}"