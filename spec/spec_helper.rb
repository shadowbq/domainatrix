require "rubygems"

begin
  require "spec"
rescue LoadError
end

# gem install redgreen for colored test output
begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end

path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)

begin
  require "lib/domainatrix"
rescue LoadError
  require 'domainatrix'
end
