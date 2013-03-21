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
    
    it "handles shouting" do
      input = "TONIGHT!!  @chelseavperetti @toddglass @dougbenson @realjeffreyross ME and Tig Notaro   http://WWW.OPCCEVENTS.ORG/"
      url = Domainatrix.scan(input).first
      url.should_not be_nil
      url.url.should == "http://www.opccevents.org/"
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

    it "removes unlikely characters from the end of URLs" do
      input = <<-TEXT
      Check out http://tobtr.com/s/821921.
      Oh, and also (http://www.google.com): Cool stuff!
      http://fora.tv/v/c8637, is almost as good as http://example.com...
      http://foo.com" <http://baz.com>
      TEXT

      urls = Domainatrix.scan(input).map {|u| u.url}
      urls.should == %w(http://tobtr.com/s/821921 http://www.google.com/ http://fora.tv/v/c8637 http://example.com/ http://foo.com/ http://baz.com/)
    end
  end

  context 'localhost with a port' do
    subject { Domainatrix.parse('localhost:3000') }
    its(:scheme) { should == 'http' }
    its(:host) { should == 'localhost' }
    its(:url) { should == 'http://localhost:3000/' }
    its(:public_suffix) { should == '' }
    its(:domain) { should == 'localhost' }
    its(:subdomain) { should == '' }
    its(:path) { should == '' }
    its(:domain_with_tld) { should == 'localhost' }
  end

  context 'without a scheme' do
    subject { Domainatrix.parse('www.pauldix.net') }
    its(:scheme) { should == 'http' }
    its(:host) { should == 'www.pauldix.net' }
    its(:url) { should == 'http://www.pauldix.net/' }
    its(:public_suffix) { should == 'net' }
    its(:domain) { should == 'pauldix' }
    its(:subdomain) { should == 'www' }
    its(:path) { should == '' }
    its(:domain_with_tld) { should == 'pauldix.net' }
  end

  context 'with a blank url' do
    subject { Domainatrix.parse(nil) }
    its(:scheme) { should == '' }
    its(:host) { should == '' }
    its(:url) { should == '' }
    its(:public_suffix) { should == '' }
    its(:domain) { should == '' }
    its(:subdomain) { should == '' }
    its(:path) { should == '' }
    its(:domain_with_tld) { should == '' }
  end

end
