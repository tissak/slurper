def details_set(entity)
  {
    :create => {
      :name => "Can create a #{entity}",
      :description => "#{entity} can be created"
    },
    :delete => {
      :name => "Can delete a #{entity}",
      :description => "#{entity} can be deleted"
    },
    :edit => {
      :name => "Can edit a #{entity}",
      :description => "#{entity} can be modified and saved."
    }
  }
end

def create_stories(entity_name)
  detail = details_set(entity_name)
  [:create,  :delete, :edit].collect { |type| create_story(entity_name, type.to_sym, detail) }
end

def create_story(entity_name, story_type, detail)
  lines = default_story_values [], entity_name
  simple_output lines, "name", detail[story_type][:name]
  simple_output lines, "description", detail[story_type][:description]
  close_output lines
  story = Story.new.parse(lines)
  story.save
end

def default_story_values(lines, entity_name)
  simple_output lines, "story_type", "feature"
  simple_output lines, "estimate", 2
  simple_output lines, "labels", entity_name
end

# print out name / value in slurp file format. Data is one line only
def simple_output(story_lines, field, value)
  story_lines.push "#{field}\n"
  story_lines.push "  #{value}\n"
end

# print out name / value in slurp file format. Data can be multi lined  
def multiline_output(story_lines, field, value)
  story_lines.push "#{field}\n"      
  value.split("\n").each do |dline|
    story_lines.push "  #{dline}\n"
  end
end

def close_output(story_lines)
  story_lines.push "==============="
end