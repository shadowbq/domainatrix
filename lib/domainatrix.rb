$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'addressable/uri'
require 'domainatrix/domain_parser.rb'
require 'domainatrix/url.rb'

begin
  require 'uri'
rescue LoadError
end

module Domainatrix
  VERSION = "0.0.8"

  def self.parse(url)
    @domain_parser ||= DomainParser.new("#{File.dirname(__FILE__)}/effective_tld_names.dat")
    Url.new(@domain_parser.parse(url))
  end

  def self.scan(text, &block)
    @schemes ||= %w(http https)

    urls = URI.extract(text, @schemes).map { |url| parse(url) }
    urls.map!(&block) if block
    urls
  end
end
