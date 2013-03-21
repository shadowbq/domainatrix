module Domainatrix
  class Error < RuntimeError; end
  class ParseError < Error; end

  class DomainParser
    include Addressable

    attr_reader :public_suffixes
    VALID_SCHEMA = /^http[s]{0,1}$/

    def initialize(file_name)
      @public_suffixes = {}
      read_dat_file(file_name)
    end

    def read_dat_file(file_name)
      # If we're in 1.9, make sure we're opening it in UTF-8
      if RUBY_VERSION >= '1.9'
        dat_file = File.open(file_name, "r:UTF-8")
      else
        dat_file = File.open(file_name)
      end
      
      dat_file.each_line do |line|
        line = line.strip
        unless (line =~ /^\/\//) || line.empty?
          parts = line.split(".").reverse

          sub_hash = @public_suffixes
          parts.each do |part|
            sub_hash = (sub_hash[part] ||= {})
          end
        end
      end
    end

    def parse(url)

      return {} unless url && url.strip != ''
      
      url = "http://#{url}" unless url[/:\/\//]
      url = url.downcase

      uri = begin
        Addressable::URI.parse(url)
      rescue Addressable::URI::InvalidURIError
        nil

      end
      
      raise ParseError, "URL is not parsable by Addressable::URI" if not uri
      
      url = uri.normalize.to_s      

      raise ParseError, "URL does not have valid scheme" unless uri.scheme =~ VALID_SCHEMA
      raise ParseError, "URL does not have a valid host" if uri.host.nil?
 
      path = uri.path
      path << "?#{uri.query}" if uri.query
      path << "##{uri.fragment}" if uri.fragment


      if uri.host == 'localhost'
        uri_hash = { :public_suffix => '', :domain => 'localhost', :subdomain => '' }
      else
        uri_hash = parse_domains_from_host(uri.host || uri.basename)
      end

      uri_hash.merge({

        :scheme => uri.scheme,
        :host   => uri.host,
        :path   => path,
        :url    => url
      })
    end

    def split_domain(parts, tld_size)
      if parts.size == 1 and tld_size == 0
        subdomain = ''
        domain = '*'
        tld = ''
      else
        # parts are host split on . reversed, eg com.pauldix.www
        domain_parts = parts.reverse
        if domain_parts.size - tld_size <= 0
          raise ParseError, "Invalid TLD size found for #{domain_parts.join('.')}: #{tld_size}"
        end

        tld = domain_parts.slice!(-tld_size, tld_size).join('.')
        domain = domain_parts.pop
        subdomain = domain_parts.join('.')
      end

      [subdomain, domain, tld]
    end

    def parse_domains_from_host(host)
      
      return {} unless host
      
      parts = host.split(".").reverse
      ip_address = false
      
      if host == '*'
        tld_size = 0
      elsif !parts.map { |part| part.match(/^\d{1,3}$/) }.include?(nil)
        # host is an ip address
        ip_address = true  
      else
        main_tld = parts.first
        tld_size = 1
        raise ParseError, "Invalid URL" if parts.size < 2
        
        if main_tld != '*'
          
          raise ParseError, "Invalid characters for TLD" unless main_tld =~ /^[a-z]{2,}/
          
          if not current_suffixes = @public_suffixes[main_tld]
            raise ParseError, "Invalid main TLD: #{main_tld}"
          end

          parts.each_with_index do |part, i|
            if current_suffixes.empty?
              # no extra rules found (eg domain.net)
              break
            else
              if current_suffixes.has_key?("!#{parts[i+1]}")
                # exception tld domain found (eg metro.tokyo.jp)
                break
              elsif current_suffixes.has_key?(parts[i+1])
                # valid extra domain level found (eg co.uk)
                tld_size += 1
                current_suffixes = current_suffixes[parts[i+1]]
              elsif current_suffixes.has_key?('*')
                # wildcard domain level (eg *.jp)
                tld_size += 1
                break
              else
                # no extra rules found (eg domain.net)
                break
              end # if current_suffixes
            end # if current_suffixes.empty?
          end # parts .. do  
        end# if main_tld
      end # if host 

      if ip_address
        subdomain, domain, tld = '', host, ''
      else
        subdomain, domain, tld = split_domain(parts, tld_size)
      end

      {:public_suffix => tld, :domain => domain, :subdomain => subdomain, :ip_address => ip_address}
    end # def
    
  end #class
end# module

