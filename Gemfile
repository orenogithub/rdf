source "https://rubygems.org"

gemspec

group :develop do
  gem 'rdf-isomorphic', github: "ruby-rdf/rdf-isomorphic",  tag: "2.0.0"
  gem "rdf-reasoner",   github: "ruby-rdf/rdf-reasoner",    tag: "0.4.0"
  gem "rdf-spec",       github: "ruby-rdf/rdf-spec",        tag: "2.0.0"
  gem "rdf-vocab",      github: "ruby-rdf/rdf-vocab",       tag: "2.0.0"
  gem "rdf-xsd",        github: "ruby-rdf/rdf-xsd",         tag: "2.0.0"

  gem 'rack',     '~> 1.0'
  gem 'rest-client-components'
  gem 'benchmark-ips'
end

group :debug do
  gem 'psych', platforms: [:mri, :rbx]
  gem "redcarpet", platforms: :ruby
  gem "byebug", platforms: :mri
  gem 'rubinius-debugger', platform: :rbx
end

group :test do
  gem "rake"
  gem "equivalent-xml"
  gem 'fasterer'
  gem 'simplecov',  require: false, platform: :mri
  gem 'coveralls',  require: false, platform: :mri
  gem "codeclimate-test-reporter", require: false
end

platforms :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'rubinius', '~> 2.0'
end
