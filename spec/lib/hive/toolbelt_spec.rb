require 'spec_helper'
require 'toolbelt'
require 'fileutils'

module Hive::Toolbelt
  describe CLI do
    describe '#create_manifest' do
      let(:cli) { described_class.new }
      let(:filename) { 'manifest.json' }

      it 'creates a manifest file' do
        cli.create_manifest
        expect(File.exists?(filename)).to be_true
      end

      def create_manifest_json config
        cli.create_manifest config
        JSON.parse File.read(filename)
      end

      it 'created manifest file has the specified config' do
        config = { foo: 1, bar: 2 }
        manifest = create_manifest_json config
        config.each do |k, v|
          expect(manifest[k.to_s]).to eq v
        end
      end

      it 'generates additional required fields' do
        config = { name: "Foo App", author: "Wei Lu" }
        manifest = create_manifest_json config

        expect(manifest["version"]).to eq("0.0.1")
        expect(manifest["icon"]).to eq("icon.png")
        expect(manifest["id"]).to eq("wei_lu.foo_app")
      end
    end

    describe '#copy_default_icon' do
      let(:cli) { described_class.new }
      let(:filename) { 'icon.png' }

      it 'provides a default icon file' do
        cli.copy_default_icon
        expect(File.exists?(filename)).to be_true
      end
    end

    describe '#create_index_html' do
      let(:cli) { described_class.new }
      let(:filename) { 'index.html' }

      it 'creates an index.html' do
        cli.create_index_html ''
        expect(File.exists?(filename)).to be_true
      end

      it 'has app name in title' do
        cli.create_index_html 'Foo App'
        index = File.read(filename)
        expect(index).to include('<title>Foo App</title>')
      end
    end

    describe '#create_readme' do
      let(:cli) { described_class.new }
      let(:filename) { 'README.md' }
      let(:project_name) { 'toolbelt' }
      let(:config) do
        {
          name: "Foo App",
          description: "Super awesome foo app",
          author: "Wei Lu",
          repo_url: "git@github.com:hivewallet/#{project_name}.git"
        }
      end
      let(:readme) do
        cli.create_readme config
        File.read(filename)
      end

      it 'creates a README.md' do
        cli.create_readme(config)
        expect(File.exists?(filename)).to be_true
      end

      it { expect(readme).to include(config[:name]) }
      it { expect(readme).to include(config[:description]) }
      it { expect(readme).to include("cd #{project_name}") }
      it { expect(readme).to include("ln -s ~/#{project_name}/ wei_lu.foo_app") }
      it { expect(readme).to include("git clone #{config[:repo_url]}") }
    end
  end
end
