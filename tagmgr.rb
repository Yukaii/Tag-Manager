#!/usr/bin/env ruby
require 'json'
require 'clamp'

module TagHelper
  extend self
  DB_NAME = "_db.json"
  DEFAULT_IGNORE_LIST = ["..", ".", DB_NAME, ".DS_Store"]

  def db_save(data)
    File.open(DB_NAME, "w") { |file| file.write(data.to_json)}
    return data
  end

  def db_load
    file = File.read(DB_NAME)
    db = JSON.parse(file)
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
      f = {:name => "", :tags => []}
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


module SimpleFm

  class AbstractCommand < Clamp::Command
    include TagHelper
  end

  class AddCommand < AbstractCommand

    option ["-t", "--tag"], "TAG", "-t yourtags, -t thistag.thattag"
    parameter "FILES ...", "the files to deal", :attribute_name => :files    
    
    def execute
      db = db_create

      (0..files.length-1).each do |i| 
        index = db.find_index {|obj| obj["name"] == files[i]}
        
        if index
          tags = db[index]["tags"]

          parse_tag(tag).each do |tag|
            if !tags.include?(tag) && tag
              db[index]["tags"].push(tag)
            end
          end

        end     
      end
      
      db_save(db)
    end

  end

  class InitCommand < AbstractCommand
    
    def execute
      if db_exist?
        puts "Database has already created..."
      end
      db_create

    end
  end

  class ListCommand < AbstractCommand

    option ["-t", "--tag"], :flag, "list all tags"
    option ["-a", "--all"], :flag, "list all include tag"
    option ["-l", "--list"], :flag, "print as list"

    def execute

      db = db_create

      if !tag?

        (0..db.length-1).each do |i|
          print "#{db[i]["name"]}"
          if all?
            print ": #{db[i]["tags"].join(", ")}\n"
          end

          if list? && !all?
            print "\n"
          elsif !all?
            print "\t"
          end
        end   

      else
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


    end
  end

  class RemoveCommand < AbstractCommand
    option ["-t", "--tag"], "TAG", "remove specific tag, multiple tags like \"tag1.tag2\""
    parameter "FILES ...", "the files to deal", :attribute_name => :files  

    def execute
      db = db_create

      if !tag 
        return
      end

      (0..files.length-1).each do |i|   
        if index = db.find_index {|obj| obj["name"] == files[i]}
          
          parse_tag(tag).each do |tag|
            if !db[index]["tags"].delete(tag)
              puts "file #{db[index]["name"]} doesn't have #{tag} tag"
            else

              puts "successfully deleted #{tag} from #{db[index]["name"]}"
              db_save(db)
            end
          end

        end
      end

    end

  end

  class SearchCommand < AbstractCommand
    # TODO: parse multiple tags
    option ["-t", "--tag"], "TAG", "\"-t tag\", or \"-t tag1&&tag2&&tag3\""

    def execute
      db = db_create
      files = []

      db.each do |f|
        if f["tags"].include?(tag)
          files.push(f["name"])
          puts f["name"]
        end
      end

    end

  end

  class MainCommand < AbstractCommand
    subcommand ["add", "a"], "add tags to files", AddCommand
    subcommand ["init", "initialize"], "initial indexes for all files", InitCommand
    subcommand ["list", "l"], "list command", ListCommand
    subcommand ["remove", "r"], "remove command", RemoveCommand
    subcommand ["search", "s"], "search by tag name", SearchCommand
  end

end

SimpleFm::MainCommand.run