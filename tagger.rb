require './tag_helper.rb'

class Tagger

  def self.add_tag(tag, files)
    db = TagHelper.db_create

    (0..files.length-1).each do |i| 
      index = db.find_index {|obj| obj["name"] == files[i]}
      
      if index
        tags = db[index]["tags"]

        TagHelper.parse_tag(tag).each do |tag|
          if !tags.include?(tag) && tag
            db[index]["tags"].push(tag)
          end
        end

      end     
    end
    
    TagHelper.db_save(db)   
  end


  def self.init
    if TagHelper.db_exist?
      puts "Database has already created..."
    end
    TagHelper.db_create
  end


  def self.print_tags
    db = TagHelper.db_create
    db = db.select {|d| d["state"] != TagHelper::STATE[2]}

    tags = []

    db.each do |f|
      f["tags"].each do |t|
        if !tags.include?(t)
          tags.push(t)
        end
      end
    end

    puts "current used tags:\n\t#{tags.join(", ")}"


  end

  def self.print_files_with_tags
    
    db = TagHelper.db_create
    db = db.select {|d| d["state"] != TagHelper::STATE[2]}

    (0..db.length-1).each do |i|
      print "#{db[i]["name"]}"
      print ": #{db[i]["tags"].join(", ")}\n"

    end       
    
  end

  def self.remove_tag(tag, files)
    db = TagHelper.db_create

    if !tag 
      return
    end

    (0..files.length-1).each do |i|   
      if index = db.find_index {|obj| obj["name"] == files[i]}
        
        TagHelper.parse_tag(tag).each do |tag|
          if !db[index]["tags"].delete(tag)
            puts "file #{db[index]["name"]} doesn't have #{tag} tag"
          else

            puts "successfully deleted #{tag} from #{db[index]["name"]}"
            TagHelper.db_save(db)
          end
        end

      end
    end
  
  end

  def self.search(tag)
    db = TagHelper.db_create
    files = []

    db.each do |f|
      if f["tags"].include?(tag)
        files.push(f["name"])
        puts f["name"]
      end
    end
  end

end