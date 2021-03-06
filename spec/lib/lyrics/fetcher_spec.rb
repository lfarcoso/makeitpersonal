# -*- coding: utf-8 -*-
require 'fast_spec_helper'
require 'lyrics/fetcher'
require 'active_support/inflector'
include ActiveSupport::Inflector, Lyrics

describe Fetcher do
  let(:fetcher) { Fetcher.new("The Gaslight anthem", "great expectations")}

  context "artist and song names" do
    it "has getters for artist format the strings" do
      fetcher.artist.should == "The_Gaslight_Anthem"
    end

    it "has getters for title format the strings" do
      fetcher.title.should == "Great_Expectations"
    end

    it "cleans the artist and song title" do
      fetcher = Fetcher.new(" The Gaslight anthem ", " great expectations ")
      fetcher.artist.should == "The_Gaslight_Anthem"
      fetcher.title.should == "Great_Expectations"
    end
  end

  context "#lyrics"  do
    let(:document) { File.dirname(__FILE__) + "/../../fixtures/song.html" }

    before do
      fetcher.stub!(:text_from_wikia).and_return(Nokogiri::HTML(open(document)))
    end

    it "fetches the lyrics from Wikia" do
      fetcher.should_receive(:text_from_wikia)
      fetcher.result.lyrics
    end

    it "parses the document and returns the lyrics" do
      fetcher.result.lyrics.should == "\nZOMGLYRICS\n"
    end

    it "doesn't return duplicate lyrics" do
      fake_document = File.dirname(__FILE__) + "/../../fixtures/song_with_duplicates.html"
      fetcher.stub!(:text_from_wikia).and_return(Nokogiri::HTML(open(fake_document)))
      fetcher.result.lyrics.should == "\nThis is so fun\n"
    end

    it "follows redirects" do
      fetcher = Fetcher.new("Mike Oldfield", "Incantations")
      fake_document = File.dirname(__FILE__) + "/../../fixtures/song_with_redirect.html"
      fetcher.stub!(:text_from_wikia).and_return(Nokogiri::HTML(open(fake_document)))
      expect { fetcher.result }.not_to raise_error
    end

    it "accepts non-alpha characters" do
      fetcher = Fetcher.new("Mike Oldfield", "Incantations (1978)")
      fetcher.result.lyrics.should == "Sorry, We don't have lyrics for this song yet."
    end
  end

  context "#lyrics_url" do
    it "encodes the url" do
      fetcher = Fetcher.new("Kraftwerk", "Geigerzähler")
      fetcher.lyrics_url.should == "http://lyrics.wikia.com/index.php?title=Kraftwerk:Geigerz%C3%A4hler&action=edit"
    end

    it "accepts ampersands in the artist's name" do
      fetcher = Fetcher.new("Coheed & Cambria", "Neverender")
      fetcher.lyrics_url.should == "http://lyrics.wikia.com/index.php?title=Coheed_%26_Cambria:Neverender&action=edit"
    end

    it "accepts ampersands in the song's name" do
      fetcher = Fetcher.new("Coheed & Cambria", "Always & Never")
      fetcher.lyrics_url.should == "http://lyrics.wikia.com/index.php?title=Coheed_%26_Cambria:Always_%26_Never&action=edit"
    end
  end

  context "#titleize" do
    it "works for names with capitals in them" do
      fetcher.titleize("LCD soundSYSTEM").should == "LCD_SoundSYSTEM"
    end
  end
end
