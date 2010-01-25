require 'active_resource'

class Story < ActiveResource::Base

  @@defaults = YAML.load_file('story_defaults.yml')
  self.site = "http://www.pivotaltracker.com/services/v2/projects/#{@@defaults['project_id']}"
  headers['X-TrackerToken'] = @@defaults.delete("token")
  attr_accessor :story_lines

  def initialize(attributes = {})
    @attributes     = {}
    @prefix_options = {}
    load(@@defaults.merge(attributes))
  end

  def parse(story_lines)
    @story_lines = story_lines
    parse_name
    parse_description
    parse_labels
    self
  end

  def updated_lines
    unless @has_id_set
      @story_lines.insert 0, "id\n"
      @story_lines.insert 1, "  #{self.id}\n"
    end
    @story_lines.push "===============\n"
    @story_lines
  end

  private
  
  def parse_id
    @story_lines.each_with_index do |line, i|
      if start_of_value?(line, 'id')
        if starts_with_whitespace?(@story_lines[i+1])
          @attributes["id"] = @story_lines[i+1].strip
          @has_id_set = true
        else
          @attributes.delete("id")
        end
      end
    end
  end

  def parse_name
    @story_lines.each_with_index do |line, i|
      if start_of_value?(line, 'name')
        if starts_with_whitespace?(@story_lines[i+1])
          @attributes["name"] = @story_lines[i+1].strip
        else
          @attributes.delete("name")
        end
      end
    end
  end

  def parse_description
    @story_lines.each_with_index do |line, i|
      if start_of_value?(line, 'description')
        desc = Array.new
        while((next_line = @story_lines[i+=1]) && starts_with_whitespace?(next_line)) do
          desc << next_line
        end
        desc.empty? ? @attributes.delete("description") : @attributes["description"] = desc.join.gsub(/^ +/, "").gsub(/^\t+/, "")
      end
    end
  end

  def parse_labels
    @story_lines.each_with_index do |line, i|
      if start_of_value?(line, 'labels')
        if starts_with_whitespace?(@story_lines[i+1])
          @attributes["labels"] = @story_lines[i+1].strip
        else
          @attributes.delete("labels")
        end
      end
    end
  end

  def starts_with_whitespace?(line)
    line && line[0,1] =~ /\s/
  end

  def start_of_value?(line, attribute)
    line[0,attribute.size] == attribute
  end

end
