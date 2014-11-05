#! /usr/bin/env ruby

require "crack"

require "./lib/fate_api"
require "./lib/authentication"
require "./lib/fate_email"

WAITING_DAYS = 5

needinfo_person = ARGV[0]
unless ARGV[0]
  warn "Please provide username/email/'full name' argument for search"
  exit 1
end

auth = Authentication.new("~/.fate.conf")
fate_api_url = ARGV[1] || auth.api_url

user = auth.user_for(fate_api_url) || `read -p "#{fate_api_url} login: " uid; echo $uid`.chomp
pass = auth.pass_for(fate_api_url) || `read -s -p "#{fate_api_url} password: " password; echo $password`.chomp

fate = FateAPI.new(user, pass, fate_api_url)

features = Crack::XML.parse(fate.get(needinfo_person))
features = features.fetch("k:collection", {}).fetch("k:object", [])

if features.size > 0
  fate_email = FateEmail.new(features, needinfo_person, WAITING_DAYS)
  puts fate_email.build
else
  warn "No features for #{needinfo_person}"
end

#
# ruby fate-checker.rb requestee@suse.com | mailx -r yast-ci@opensuse.org -s "FATE: Information Still Needed" requestee@suse.com
#