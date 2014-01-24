require 'spec_helper'
require 'toolbelt'

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

      after do
        File.delete filename if File.exists?(filename)
      end
    end

    describe '#copy_default_icon' do
      let(:cli) { described_class.new }
      let(:filename) { 'icon.png' }

      it 'provides a default icon file' do
        cli.copy_default_icon
        expect(File.exists?(filename)).to be_true
      end

      after do
        File.delete filename if File.exists?(filename)
      end
    end
  end
end
