# Jewel

Gem metadata at your fingertips.

# What's this for?

Sometimes it's useful to access information about a gem at runtime. Jewel exists
to centralize access to that data and make it as easy as possible to access it.

# How do I install it?

Latest version:

    gem install jewel

From source:

    git clone git://github.com/matheusmoreira/jewel.git

# How do I use it?

Let's say you have a gem named `awesome`. Let's define the `Awesome::Gem` class:

    # lib/awesome/gem.rb
    require 'jewel'

    module Awesome
      class Gem < Jewel::Gem
        name! :awesome
        summary 'Awesome gem'
        version '1.2.3'
        homepage 'https://github.com/you/awesome'

        author 'You'
        email 'you@awesome.com'

        root '../..'  # relative to this file's directory
        files `git ls-files`.split "\n"

        depend_on :jewel
      end
    end

Now you and others can access your specification at runtime. Let's use it to
set up the `awesome.gemspec` file:

    #!/usr/bin/env gem build
    # encoding: utf-8
    require './awesome/gem'

    Awesome::Gem.specification

Tools like `gem` and `bundler` assume the `.gemspec` returns a
`Gem::Specification` instance, which is exactly what is happening here.

# External libraries? In _my_ `.gemspec`?!

Right. Unlike `.gemspec` generators, Jewel will not duplicate information and it
will _certainly_ not make a giant mess in your version control diff. These are
actually some of the reasons why I wrote this gem.

However, you will probably run into problems if you use tools that parse your
`.gemspec` or are unable to `require` your gem. If that's your case, then you'll
be happy to know that you can also use your existing handwritten
specification:

    # lib/awesome/gem.rb
    require 'jewel'

    module Awesome
      class Gem < Jewel::Gem
        root '../..'
        path_to_gemspec = root.join 'awesome.gemspec'

        # specification is aliased as spec
        spec ::Gem::Specification.load path_to_gemspec.to_s
      end
    end

Hey, is that a `Rails.root`-like method? Exactly! It basically returns a dynamic
Pathname allows you join paths by chaining methods and passing arguments to
them:

    root = Awesome::Gem.root
    root.lib.awesome 'gem.rb'  # lib/awesome/gem.rb
    root.i18n I18n.locale.to_s, 'messages.yml'  # i18n/en/messages.yml

# Nifty. What else can it do?

It can make sure that the correct versions of your dependencies will be loaded.
When you `require` some code, RubyGems will actually load the latest version of
the gem that it can find, even if you've specified a lower version in the
specification. To make it load the versions you wanted, you can simply write:

    Awesome::Gem.activate_dependencies!

You can browse the [documentation](http://rubydoc.info/gems/jewel/frames) in
order to learn more about the general API. There is also [edge
documentation](http://rubydoc.info/github/matheusmoreira/jewel/master/frames),
straight from the GitHub repository.

# Hey, it's broken!! Why doesn't it do this?

Found problems? Have ideas? The best way to get in touch is to [create an
issue](https://github.com/matheusmoreira/jewel/issues/new) on the GitHub
tracker. Feel free to fork the repository send a pull request as well!
