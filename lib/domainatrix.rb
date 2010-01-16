$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'addressable/uri'
require 'domainatrix/domain_parser.rb'
require 'domainatrix/url.rb'

module Domainatrix
  VERSION = "0.0.9"
  DOMAIN_PARSER = DomainParser.new("#{File.dirname(__FILE__)}/effective_tld_names.dat")

  def self.parse(url)
    Url.new(DOMAIN_PARSER.parse(url))
  end

  def self.scan(text, &block)
    @schemes ||= %w(http https)

    urls = URI.extract(text, @schemes).map { |url| parse(url) }
    urls.map!(&block) if block
    urls
  end
end
