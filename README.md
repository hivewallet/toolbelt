# Hive::Toolbelt

Command Line Interface for the Hive wallet

## Installation

    $ gem install hive-toolbelt

## Usage

    $ hive init     # walk you through scaffolding a Hive app
    $ hive package  # creates a .hiveapp bundle from specified or current working directory (.hidden files ignored)
    $ hive release  # (TODO) bumps version, tags and pushes

### hive init

    $ mkdir new_app
    $ cd new_app
    $ hive init

`hive init` asks questions and scaffolds a Hive app. It

- creates manifest.json. Read more on [manifest configuration](https://github.com/hivewallet/hive-osx/wiki/How-to-build-a-Hive-app#wiki-manifest-file) 
- creates a skeleton index.html. Read more on [index.html](https://github.com/hivewallet/hive-osx/wiki/How-to-build-a-Hive-app#wiki-index-page)
- provides a default icon
- generates basic app structure. Read more on [app structure](https://github.com/hivewallet/hive-osx/wiki/How-to-build-a-Hive-app#wiki-app-structure)
- includes a [mock Hive API](https://github.com/javgh/hiveapp-api-mock/blob/v1.0.1/hiveapp-api-mock.js) for in-browser development & testing
 
### hive package

`hive package [DIR_NAME]` packages a directory into a .hiveapp bundle. `DIR_NAME` defaults to current working directory if not specified. Regardless of `DIR_NAME`, the generated `.hiveapp` bundle is always located at current working directory.

Note that the command deliberately exclude all .hidden files and directories, like `.git`, when generating the bundle. 

## Contributing

1. Fork it ( http://github.com/hivewallet/hive-toolbelt/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
