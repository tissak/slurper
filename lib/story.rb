require 'active_resource'

class Story < ActiveResource::Base

  @@defaults = YAML.load_file('story_defaults.yml')
  self.site = "http://www.pivotaltracker.com/services/v2/projects/#{@@defaults['project_id']}"
  headers['X-TrackerToken'] = @@defaults.delete("token")
  attr_accessor :story_lines, :has_id_set

  def initialize(attributes = {})
    @has_id_set     = false
    @attributes     = {}
    @prefix_options = {}    
    load(@@defaults.merge(attributes))
  end
  
  # deconstruct an entry into attributes to submit
  def parse(story_lines)
    @story_lines = story_lines.clone
    parse_id
    parse_for("name")
    parse_requested_by
    parse_estimate
    parse_description
    parse_for("labels")
    # do last just in case chore / bug requires resetting estimate
    parse_story_type
    self
  end
  
  # take the existing lines and insert an ID if newly created
  def updated_lines
    unless @has_id_set
      @story_lines.insert 0, "id\n"
      @story_lines.insert 1, "  #{self.id}\n"
    end
    @story_lines.push "===============\n"
    @story_lines
  end
  
  # take the current AR object and turn into lines for slurp file storage
  def slurper_serialize
    @keys = @attributes.keys
    story_lines = []
    simple_output story_lines, "id"
    simple_output story_lines, "name"
    simple_output story_lines, "requested_by"
    simple_output story_lines, "estimate"
    simple_output story_lines, "story_type"
    multiline_output story_lines, "description"
    simple_output story_lines, "labels"
    story_lines.push "===============\n"
    story_lines
  end

  private
  
  # print out name / value in slurp file format. Data is one line only
  def simple_output(story_lines, field)
    if @keys.include? field
      story_lines.push "#{field}\n"
      story_lines.push "  #{@attributes[field]}\n"
    end
  end

  # print out name / value in slurp file format. Data can be multi lined  
  def multiline_output(story_lines, field)
    if @keys.include? field
      story_lines.push "#{field}\n"      
      unless @attributes[field].nil?
        @attributes[field].split("\n").each do |dline|
          story_lines.push "  #{dline}\n"
        end
      end
    end
  end

  # generic search for item.
  def parse_for(item_name)
    return_val = false
    @story_lines.each_with_index do |line, i|
      if start_of_value?(line, item_name)
        if starts_with_whitespace?(@story_lines[i+1])
          @attributes[item_name] = @story_lines[i+1].strip
          return_val = true
        else
          @attributes.delete(item_name)
        end
      end
    end
    return_val
  end
  
  # only let restricted types through - bug, chore, feature
  def parse_story_type
    parse_for("story_type")
    unless @attributes["story_type"].nil?
      unless ["chore","bug","feature"].include?(@attributes["story_type"])
        @attributes.delete("story_type") 
      else
        # when creating a chore / bug there is no estimate.
        @attributes["estimate"] = -1 if ["chore","bug"].include?(@attributes["story_type"])
      end
    end
  end
  
  # standard approach only we need to track if we set an id for updating the source file
  def parse_id
    @has_id_set = parse_for("id")
  end
  
  # standard approach only if we don't find one, leave the existing default intact
  def parse_requested_by
    @story_lines.each_with_index do |line, i|
      if start_of_value?(line, "requested_by")
        if starts_with_whitespace?(@story_lines[i+1])
          @attributes["requested_by"] = @story_lines[i+1].strip
        end
      end
    end
  end
  
  # make sure the value is int and within range.
  def parse_estimate
    estimate = parse_for "estimate"
    unless @attributes["estimate"].nil?
      val = @attributes["estimate"].to_i
      val = (val > 3 || val < -1) ? -1 : val
      @attributes["estimate"] = val
    end
  end

  # handle multi line descriptions
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

  def starts_with_whitespace?(line)
    line && line[0,1] =~ /\s/
  end

  def start_of_value?(line, attribute)
    line[0,attribute.size] == attribute
  end

end
