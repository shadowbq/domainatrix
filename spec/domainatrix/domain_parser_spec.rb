# -*- encoding : utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe "domain parser" do
  before(:all) do
    @domain_parser = Domainatrix::DomainParser.new("#{File.dirname(__FILE__)}/../../lib/effective_tld_names.dat")
  end

  describe "reading the dat file" do
    it "creates a tree of the domain names" do
      @domain_parser.public_suffixes.should be_a Hash
    end

    it "creates the first level of the tree" do
      @domain_parser.public_suffixes.should have_key("com")
    end

    it "creates the first level of the tree even when the first doesn't appear on a line by itself" do
      @domain_parser.public_suffixes.should have_key("uk")
    end

    it "creates lower levels of the tree" do
      @domain_parser.public_suffixes["jp"].should have_key("ac")
      @domain_parser.public_suffixes["jp"]["kawasaki"].should have_key("*")
    end
  end

  describe "parsing" do
    it "returns a hash of parts" do
      @domain_parser.parse("http://pauldix.net").should be_a Hash
    end

    it "includes the original url" do
      @domain_parser.parse("http://www.pauldix.net")[:url].should == "http://www.pauldix.net/"
    end

    it "includes the scheme" do
      @domain_parser.parse("http://www.pauldix.net")[:scheme].should == "http"
    end

    it "includes the full host" do
      @domain_parser.parse("http://www.pauldix.net")[:host].should == "www.pauldix.net"
    end

    it "parses out the path" do
      @domain_parser.parse("http://pauldix.net/foo.html?asdf=foo#bar")[:path].should == "/foo.html?asdf=foo#bar"
      @domain_parser.parse("http://pauldix.net/foo.html?asdf=foo")[:path].should == "/foo.html?asdf=foo"
      @domain_parser.parse("http://pauldix.net?asdf=foo")[:path].should == "?asdf=foo"
      @domain_parser.parse("http://pauldix.net")[:path].should == ""
    end

    it "parses the tld" do
      @domain_parser.parse("http://pauldix.net")[:public_suffix].should == "net"
      @domain_parser.parse("http://pauldix.co.uk")[:public_suffix].should == "co.uk"
      @domain_parser.parse("http://pauldix.com.kg")[:public_suffix].should == "com.kg"
      @domain_parser.parse("http://pauldix.com.kawasaki.jp")[:public_suffix].should == "com.kawasaki.jp"
    end

    it "should have the domain" do
      @domain_parser.parse("http://pauldix.net")[:domain].should == "pauldix"
      @domain_parser.parse("http://foo.pauldix.net")[:domain].should == "pauldix"
      @domain_parser.parse("http://pauldix.co.uk")[:domain].should == "pauldix"
      @domain_parser.parse("http://foo.pauldix.co.uk")[:domain].should == "pauldix"
      @domain_parser.parse("http://pauldix.com.kg")[:domain].should == "pauldix"
      @domain_parser.parse("http://pauldix.com.kawasaki.jp")[:domain].should == "pauldix"
    end

    it "should have subdomains" do
      @domain_parser.parse("http://foo.pauldix.net")[:subdomain].should == "foo"
      @domain_parser.parse("http://bar.foo.pauldix.co.uk")[:subdomain].should == "bar.foo"
    end

    it "parses a link to localhost" do
      parsed = @domain_parser.parse("http://localhost")
      parsed[:host].should == "localhost"
      parsed[:url].should == "http://localhost/"
      parsed[:domain].should == "localhost"
      parsed[:public_suffix].should == ""
    end

    it "should accept wildcards" do
      @domain_parser.parse("http://*.pauldix.net")[:subdomain].should == "*"
      @domain_parser.parse("http://pauldix.*")[:public_suffix].should == "*"
      @domain_parser.parse("http://pauldix.net/*")[:path].should == "/*"

      combined = @domain_parser.parse("http://*.pauldix.*/*")
      combined[:subdomain].should == "*"
      combined[:domain].should == "pauldix"
      combined[:public_suffix].should == "*"
      combined[:path].should == "/*"
    end

    it "should parse a URL if it has a wildcard exception" do
      @domain_parser.parse("http://metro.tokyo.jp")[:domain].should == "metro"
    end

    it "should throw an exception if the tld is not valid" do
      lambda { @domain_parser.parse("http://pauldix.nett") }.should raise_error(Domainatrix::ParseError)
    end

    it "should throw an exception if the domain doesn't contain a valid host" do
      lambda { @domain_parser.parse("http://co.jp") }.should raise_error(Domainatrix::ParseError)
    end

    it "should throw an exception if the domain contains an invalid character" do
      lambda { @domain_parser.parse("http://pauldix,net") }.should raise_error(Domainatrix::ParseError)
    end
    
    it "should thrown an exception if the url is malformed" do
      lambda { @domain_parser.parse("http:/") }.should raise_error(Domainatrix::ParseError)
    end

    it "parses an ip address" do
      @domain_parser.parse("http://123.123.123.123/foo/bar")[:domain].should == "123.123.123.123"
      @domain_parser.parse("http://123.123.123.123/foo/bar")[:path].should == "/foo/bar"
      @domain_parser.parse("http://123.123.123.123/foo/bar")[:ip_address].should == true
    end

    it "parses a host with numeric domain" do
      @domain_parser.parse("http://123.123.123.co.uk/foo/bar")[:subdomain].should == "123.123"
      @domain_parser.parse("http://123.123.123.co.uk/foo/bar")[:domain].should == "123"
      @domain_parser.parse("http://123.123.123.co.uk/foo/bar")[:public_suffix].should == "co.uk"
      @domain_parser.parse("http://123.123.123.co.uk/foo/bar")[:ip_address].should == false
    end

    it "should not parse an invalid ip address" do
      lambda { @domain_parser.parse("http://12345") }.should raise_error(Domainatrix::ParseError)
    end
    
    it "defaults to http if no scheme is applied" do
      @domain_parser.parse("www.pauldix.net")[:host].should == "www.pauldix.net"
      @domain_parser.parse("www.pauldix.net")[:scheme].should == "http"
    end

  end
  
  describe "handling utf-8" do
    
    it "handles public suffixes with utf-8" do
      @domain_parser.parse("http://pauldix.السعوديه")[:public_suffix].should == "السعوديه"
      @domain_parser.parse("http://pauldix.臺灣")[:public_suffix].should == "臺灣"
      @domain_parser.parse("http://pauldix.السعوديه")[:domain].should == "pauldix"
      @domain_parser.parse("http://pauldix.臺灣")[:domain].should == "pauldix"
    end
    
    it "handles unicode urls as puny code" do
       input = "http://✪df.ws/fil"
       parsed = @domain_parser.parse(input)
       parsed[:url].should == "http://xn--df-oiy.ws/fil"
       parsed[:host].should == "✪df.ws"
       parsed[:path].should == "/fil"
       parsed[:public_suffix].should == "ws"
    end
    
  end
  
end
