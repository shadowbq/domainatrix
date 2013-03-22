$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'addressable/uri'
require 'domainatrix/domain_parser'
require 'domainatrix/url'
require 'uri'

begin
  require 'uri'
rescue LoadError
end

module Domainatrix
  
  #Keep Constant for backwards compat
  DOMAIN_PARSER = DomainParser.new("#{File.dirname(__FILE__)}/effective_tld_names.dat")
  
  def self.icann_parse(url, dat = "#{File.dirname(__FILE__)}/effective_tld_names.dat", sections = ["ICANN DOMAINS"])
    Url.new(DomainParser.new(dat, sections).parse(url))
  end
  
  def self.custom_parse(url, dat = "#{File.dirname(__FILE__)}/effective_tld_names.dat", sections = ["ICANN DOMAINS"])
    Url.new(DomainParser.new(dat, sections).parse(url))
  end
  
  def self.parse(url)
    #Url.new(DomainParser.parse(url)) #<-- Still slow implementation at this point
    Url.new(DOMAIN_PARSER.parse(url))
  end

  def self.scan(text, &block)
    return [] unless text
    @schemes ||= %w(http https)
    all_trailing_clutter = /[.,:);]+$/
    clutter_without_parens = /[.,:);]+$/

    candidate_urls = ::URI.extract(text, @schemes)
    candidate_urls.map! do |url|
      # If the URL has an open paren, allow closing parens.
      if url.include?("(")
        url.gsub(clutter_without_parens, '')
      else
        url.gsub(all_trailing_clutter, '')
      end
    end

    urls = candidate_urls.map do |url|
      begin
        parse(url)
      rescue Addressable::URI::InvalidURIError
      end
    end.compact

    urls.map!(&block) if block
    urls
  end

end