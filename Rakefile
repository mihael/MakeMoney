require 'rubygems'
require 'rake'
#require 'rake/testtask'
#require 'rake/rdoctask'

desc "pushup to git.rubynarails.com"
task :pushup => :environment do
  exec "git push original master:refs/heads/master"
end