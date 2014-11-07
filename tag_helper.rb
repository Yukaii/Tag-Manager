module TagHelper
  extend self
  DB_NAME = "_db.json"
  DEFAULT_IGNORE_LIST = ["..", ".", DB_NAME, ".DS_Store"]
  STATE = ["new", "modified", "deleted"]

  def db_save(data)
    File.open(DB_NAME, "w") { |file| file.write(data.to_json)}
    return data
  end

  def db_check(db)
    filenames = Dir.entries(".")
    current_names = db.map {|f| f["name"]}

    current_names.each do |name|
      if !filenames.include?(name)
        _i = db.find_index {|d| d["name"] == name}
        db[_i]["state"] = STATE[2]
      end
    end

    return db
  end

  def db_load
    file = File.read(DB_NAME)
    db = JSON.parse(file)
    db_check(db)
  end

  def db_exist?
    File.exist?(DB_NAME)
  end

  def db_empty?
    File.zero?(DB_NAME)
  end

  def db_init
    filenames = Dir.entries(".")

    file_array = []
    (0..filenames.length-1).each do |i|
      f = {:name => "", :tags => [], :state => STATE[0]}
      f[:name] = filenames[i]

      if !DEFAULT_IGNORE_LIST.include?(f[:name])
        file_array.push(f)
      end

    end

    return file_array
  end

  def db_create
      
    if !db_exist? || db_empty?
      db_save(db_init)
    else
      db_load
    end
  end  

  def parse_tag(tags)
    tags.split(".")
  end

end

# class FileFormat
#   attr_accessor :name, :tags
  
#   def initialize
#     @name = ""
#     @tags = []
#   end

#   def to_json
#     {'name' => name, 'tags' => tags}.to_json
#   end
# end