module Domainatrix
  class Url

    attr_accessor :public_suffix, :domain, :subdomain, :path, :url, :scheme, :host, :ip_address

    def initialize(attrs = {})
      @scheme = attrs[:scheme] || ''
      @host = attrs[:host] || ''
      @url = attrs[:url] || ''
      @public_suffix = attrs[:public_suffix] || ''
      @domain = attrs[:domain] || ''
      @subdomain = attrs[:subdomain] || ''
      @path = attrs[:path] || ''
      @ip_address = attrs[:ip_address]

    end

    def canonical(options = {})
      public_suffix_parts = @public_suffix.split(".")
      url = "#{public_suffix_parts.reverse.join(".")}.#{@domain}"
      if @subdomain && !@subdomain.empty?
        subdomain_parts = @subdomain.split(".")
        url << ".#{subdomain_parts.reverse.join(".")}"
      end
      url << @path if @path

      url
    end

    def domain_with_public_suffix
      [@domain, @public_suffix].compact.reject{|s|s==''}.join('.')
    end
    alias domain_with_tld domain_with_public_suffix

    def to_s
      if @scheme.nil? || @scheme.empty?
        scheme = ''
      else
        scheme = "#{@scheme}://"
      end  
      
      parts = []
      parts << @subdomain if @subdomain and !@subdomain.empty?
      parts << @domain if @domain and !@domain.empty?
      parts << @public_suffix if @public_suffix and !@public_suffix.empty?

      "#{scheme}#{parts.join('.')}#{@path}"
    end

  end
end
