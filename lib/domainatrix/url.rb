module Domainatrix
  class Url
    attr_accessor :public_suffix, :domain, :subdomain, :path, :url, :scheme, :host, :ip_address

    def initialize(attrs = {})
      @scheme = attrs[:scheme]
      @host = attrs[:host]
      @url = attrs[:url]
      @public_suffix = attrs[:public_suffix]
      @domain = attrs[:domain]
      @subdomain = attrs[:subdomain]
      @path = attrs[:path]
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

    def to_s
      scheme = (@scheme.nil?) ? '' : "#{@scheme}://"
      parts = []
      parts << @subdomain if @subdomain and !@subdomain.empty?
      parts << @domain if @domain and !@domain.empty?
      parts << @public_suffix if @public_suffix and !@public_suffix.empty?

      "#{scheme}#{parts.join('.')}#{@path}"
    end
  end
end
