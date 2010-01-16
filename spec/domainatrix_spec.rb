require File.dirname(__FILE__) + '/spec_helper'

describe Domainatrix do
  describe ".parse" do
    it "should convert a string into a url object" do
      Domainatrix.parse("http://pauldix.net").should be_a Domainatrix::Url
    end

    it "should canonicalize" do
      Domainatrix.parse("http://pauldix.net").canonical.should == "net.pauldix"
      Domainatrix.parse("http://pauldix.net/foo.html").canonical.should == "net.pauldix/foo.html"
      Domainatrix.parse("http://pauldix.net/foo.html?asdf=bar").canonical.should == "net.pauldix/foo.html?asdf=bar"
      Domainatrix.parse("http://foo.pauldix.net").canonical.should == "net.pauldix.foo"
      Domainatrix.parse("http://foo.bar.pauldix.net").canonical.should == "net.pauldix.bar.foo"
      Domainatrix.parse("http://pauldix.co.uk").canonical.should == "uk.co.pauldix"
    end
  end

  describe ".scan" do
    it "parses the url found in a string" do
      input = "HAHA. This is why Conan should stay: http://losangeles.craigslist.org/sfv/clt/1551463643.html"
      url = Domainatrix.scan(input).first
      url.canonical.should == "org.craigslist.losangeles/sfv/clt/1551463643.html"
    end

    it "finds multiple urls in a string" do
      input = <<-TEXT
      http://google.com
      and then http://yahoo.com
      TEXT
      google, yahoo = Domainatrix.scan(input)
      google.domain.should == "google"
      yahoo.domain.should == "yahoo"
    end

    it "returns a map of results when given a block" do
      input = "http://a.com https://b.com"
      domains = Domainatrix.scan(input) do |url|
        url.domain
      end
      domains.should == %w(a b)
    end

    it "returns an empty array when no urls are found" do
      Domainatrix.scan("Nope").should == []
    end
  end
end
