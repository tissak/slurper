require 'rubygems'
require 'spec'
require 'story'

describe Story do

  it ".parse should return a reference to the story" do
    story = Story.new
    story.parse("").should == story
  end

  context "deals with leading/trailing whitespace" do
    before do
      story_lines = IO.readlines(File.dirname(__FILE__) + "/whitespacey_story.txt")
      @story = Story.new.parse(story_lines)
    end

    it "strips whitespace from the name" do
      @story.name.should == "Profit"
    end

    it "strips whitespace from the description" do
      @story.description.should == "In order to do something\nAs a role\nI want to click a thingy\n"
    end
  end

  context "given values for all base attributes" do
    before do
      story_lines = IO.readlines(File.dirname(__FILE__) + "/full_story.txt")
      @story = Story.new.parse(story_lines)
    end

    it "parses the name correctly" do
      @story.name.should == "Profit"
    end

    it "parses the description correctly" do
      @story.description.should == "In order to do something\nAs a role\nI want to click a thingy\n\nAcceptance:\n* do the thing\n* don't forget the other thing\n"
    end

    it "parses the label correctly" do
      @story.labels.should == "money,power,fame"
    end
  end

  context "given values for full attributes" do
    before do
      story_lines = IO.readlines(File.dirname(__FILE__) + "/fuller_story.txt")
      @story = Story.new.parse(story_lines)
    end

    it "parses the id correctly" do
      @story.id.should == "2284153"
    end
    
    it "parses the name correctly" do
      @story.name.should == "Next Story about UI Update"
    end
    
    it "parses the requested by correctly" do
      @story.requested_by.should == "James Brown"
    end
    
    it "parses the estimate correctly" do
      @story.estimate.should == 2
    end

    it "parses the description correctly" do
      @story.description.should == "Something exciting to do with the UI. \nWith an update.\n"
    end

    it "parses the label correctly" do
      @story.labels.should == "ui,story"
    end
  end

  # chores and bugs do not have estimates
  context "for chore stories" do
    before do
      story_lines = IO.readlines(File.dirname(__FILE__) + "/chore_story.txt")
      @story = Story.new.parse(story_lines)
    end
    
    it "parses the owner correctly" do
      @story.requested_by.should == "Donald Smith"
    end

    it "parses and corrects the estimate correctly" do
      @story.estimate.should == -1
    end
  end

  context "given only a name" do
    before do
      story_lines = IO.readlines(File.dirname(__FILE__) + "/name_only.txt")
      @story = Story.new.parse(story_lines)
    end

    it "should parse the name correctly" do
      @story.name.should == "Profit"
    end

  end

  context "given empty attributes" do
    before do
      story_lines = IO.readlines(File.dirname(__FILE__) + "/empty_attributes.txt")
      @story = Story.new.parse(story_lines)
    end

    it "should not set any name" do
      @story.attributes.keys.should_not include("name")
    end

    it "should not set any description" do
      @story.attributes.keys.should_not include("description")
    end

    it "should not set any labels" do
      @story.attributes.keys.should_not include("labels")
    end
  end

  context "given attributes with spaces" do
    before do
      story_lines = IO.readlines(File.dirname(__FILE__) + "/quoted_attributes.txt")
      @story = Story.new.parse(story_lines)
    end

    it "should set the description correctly" do
      @story.description.should == "I have a \"quote\"\n"
    end
  end

end
