require "thor"
require "json"
require "active_support"
require "active_support/core_ext/string"
require "active_support/core_ext/hash"
require "zip"
require "webrick"

I18n.enforce_available_locales = false

module Hive
  module Toolbelt
    class CLI < Thor
      MANIFEST = "manifest.json"
      INDEX = "index.html"
      ICON = "icon.png"
      README = "README.md"
      LICENSE = "MIT-LICENSE.txt"

      desc "init", "scaffold a Hive app"
      def init
        config = {}
        config[:name] = ask("App Name: ")
        config[:description] = ask("Description: ")
        config[:author] = ask("Author Name: ")
        config[:contact] = ask("Author Contact: ")
        config[:repoURL] = ask("Git Repository URL: ")
        config[:accessedHosts] = ask("API hosts the app needs to talk to (separated by comma. e.g. api.github.com, www.bitstamp.net): ")

        create_manifest(config)
        copy_default_icon
        copy_api_mock # for in-browser development
        create_index_html config[:name]
        create_readme config
        create_license config[:author]
        create_empty_folders
      end

      desc "package [DIR_NAME]", "package a directory into a .hiveapp bundle. DIR_NAME defaults to current working directory if not specified."
      def package dir_name='.'
        directory = sanitize_dir_name dir_name
        check_for_required_files directory

        bundle_name = bundle_name_from_manifest(File.join directory, MANIFEST)
        FileUtils.rm(bundle_name) if File.exists? bundle_name
        bundle_files bundle_name, directory

        say "#{bundle_name} packaged successfully", :green
      rescue PackageError => e
        say e.message, :red
      end

      desc "serve [PORT] [DIR_NAME]", "serve a directory as a .hiveapp bundle by setting up a local registry. PORT defaults to 8888, DIR_NAME defaults to the current working directory."
      def serve port=8888, dir_name='.'
        directory = sanitize_dir_name dir_name
        check_for_required_files directory

        manifest = File.join directory, MANIFEST
        bundle_name = bundle_name_from_manifest manifest
        start_registry port, manifest, directory, bundle_name
      rescue PackageError => e
        say e.message, :red
      end

      no_commands do
        include Thor::Actions
        self.source_paths << File.join(File.dirname(__FILE__), '..', '..', '..', 'assets')

        def create_manifest config={}
          defaults = {
            version: "0.0.1",
            icon: ICON,
            id: id_for(config[:author], config[:name])
          }

          File.open(MANIFEST, 'w') do |f|
            config[:accessedHosts] = config[:accessedHosts].split(',').map(&:strip)
            f.puts(JSON.pretty_generate config.merge(defaults))
          end
        end

        def id_for author, name
          return "" if author.blank? || name.blank?
          "#{author.parameterize}.#{name.parameterize}"
        end

        def copy_default_icon
          copy_file File.join('images', ICON), ICON
        end

        def copy_api_mock
          filename = File.join('javascripts', 'hiveapp-api-mock.js')
          copy_file filename, filename
        end

        def create_index_html title
          copy_file File.join('html', INDEX), INDEX
          gsub_file INDEX, /{{title}}/, title
        end

        def create_readme config
          copy_file README, README
          safe_gsub_file README, /{{name}}/, config[:name]
          safe_gsub_file README, /{{description}}/, config[:description]
          safe_gsub_file README, /{{app_id}}/, id_for(config[:author], config[:name])
          safe_gsub_file README, /{{repo_url}}/, config[:repoURL]
          safe_gsub_file README, /{{project_name}}/, project_name_from(config[:repoURL])
        end

        def safe_gsub_file filename, pattern, replacement
          return if replacement.blank?

          gsub_file filename, pattern, replacement
        end

        def project_name_from repo_url
          return if repo_url.blank?

          repo_url.split('/').last.gsub(/.git$/, '')
        end

        def create_license author
          copy_file LICENSE, LICENSE
          safe_gsub_file LICENSE, /{{year}}/, Time.now.year.to_s
          safe_gsub_file LICENSE, /{{author}}/, author
        end

        def create_empty_folders
          %w(stylesheets images fonts).each do |dirname|
            create_file File.join(dirname, '.gitignore')
          end
        end

        def sanitize_dir_name dir_name
          directory = File.expand_path dir_name
          directory << File::SEPARATOR unless directory.ends_with?(File::SEPARATOR)
          directory
        end

        def check_for_required_files sanitized_dir_name
          [INDEX, MANIFEST].each do |filename|
            if Dir.glob(File.join sanitized_dir_name, filename).empty?
              raise PackageError.new("#{filename} is required. But it's not found under #{sanitized_dir_name}")
            end
          end
        end

        def bundle_files bundle_name, directory
          Zip::File.open(bundle_name, Zip::File::CREATE) do |zipfile|
            Dir[File.join(directory, '**', '**')].each do |file|
              zipfile.add(file.sub(directory, ''), file)
            end
          end
        end

        def bundle_name_from_manifest manifest
          config = JSON.parse(File.read manifest).with_indifferent_access
          required = config.slice :author, :name, :version

          required.each do |k, v|
            raise PackageError.new("Please provide a value for `#{k}` field in #{MANIFEST}") if v.blank?
          end

          required.values.join(' ').parameterize << '.hiveapp'
        end

        def start_registry port, manifest, directory, bundle_name
          config = JSON.parse(File.read manifest).with_indifferent_access
          raise PackageError.new("Please provide an id in the manifest") unless config.include? :id
          raise PackageError.new("Please set an icon in the manifest") unless config.include? :icon
          id = config[:id]
          icon_path = config[:icon]
          icon_file = File.join directory, icon_path

          server = WEBrick::HTTPServer.new :Port => port
          trap 'INT' do server.shutdown end
          server.mount_proc '/index.json' do |req, res|
            res.keep_alive = false
            res.content_type = 'text/json'
            res.body = "[" + (File.read manifest) + "]"
          end
          server.mount_proc ('/' + id + '.hiveapp') do |req, res|
            FileUtils.rm(bundle_name) if File.exists? bundle_name
            bundle_files bundle_name, directory
            res.keep_alive = false
            res.body = File.read bundle_name
          end
          server.mount_proc ('/' + id + '/' + icon_path) do |req, res|
            res.keep_alive = false
            res.body = File.read icon_file
          end
          server.start
        end
      end
    end
  end
end

