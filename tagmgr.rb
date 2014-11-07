#!/usr/bin/env ruby
require 'json'
require 'clamp'
require './tagger.rb'

module TagManager 

  class AddCommand < Clamp::Command

    option ["-t", "--tag"], "TAG", "-t yourtags, -t thistag.thattag"
    parameter "FILES ...", "the files to deal", :attribute_name => :files    
    
    def execute
      Tagger.add_tag(tag, files)
    end

  end

  class InitCommand < Clamp::Command
    
    def execute
      Tagger.init
    end
  end

  class ListCommand < Clamp::Command

    self.default_subcommand = "all"

    subcommand ["all", "a"], "list all file tags" do
      def execute
        Tagger.print_files_with_tags
      end     
    end

    subcommand ["tags", "tag", "t"], "list current tags" do
      def execute
        Tagger.print_tags
      end
    end

  end

  class RemoveCommand < Clamp::Command
    option ["-t", "--tag"], "TAG", "remove specific tag, multiple tags like \"tag1.tag2\""
    parameter "FILES ...", "the files to deal", :attribute_name => :files  

    def execute
      Tagger.remove_tag(tag, files)
    end

  end

  class SearchCommand < Clamp::Command
    # TODO: parse multiple tags
    option ["-t", "--tag"], "TAG", "\"-t tag\", or \"-t tag1&&tag2&&tag3\""

    def execute
      Tagger.search(tag)
    end

  end

  class MainCommand < Clamp::Command
    subcommand ["add", "a"], "add tags to files", AddCommand
    subcommand ["init", "initialize"], "initial indexes for all files", InitCommand
    subcommand ["list", "l"], "list command", ListCommand
    subcommand ["remove", "r"], "remove command", RemoveCommand
    subcommand ["search", "s"], "search by tag name", SearchCommand
  end

end

TagManager::MainCommand.run