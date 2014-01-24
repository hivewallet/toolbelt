#!/usr/bin/ruby

require "thor"
require "json"
require_relative "toolbelt/version"

module Hive
  module Toolbelt
    class CLI < Thor
      desc "init", "scaffolding a Hive app"
      def init
        config = {}
        config[:name] = ask("App Name: ")
        config[:description] = ask("Description: ")
        config[:author] = ask("Author Name: ")
        config[:contact] = ask("Author Contact: ")
        config[:repo_url] = ask("Git Repository URL: ")

        create_manifest(config)
      end

      no_commands do
        def create_manifest config={}
          File.open('manifest.json', 'w') do |f|
            f.puts(JSON.pretty_generate config)
          end
        end
      end
    end
  end
end

Hive::Toolbelt::CLI.start
