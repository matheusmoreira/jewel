require 'jewel'

describe Jewel::Gem do

  let(:example_name) { :example }
  let(:example_summary) { 'Example description' }
  let(:example_version) { '1.2.3' }
  let(:example_homepage) { 'https://github.com/example/example' }
  let(:example_license) { 'Mozilla Public License, version 2.0' }

  let(:example_author) { 'Person' }
  let(:example_email) { 'person@example.com' }

  let(:example_files) { [] }

  let(:example_runtime_dependency) { 'jewel' }
  let(:example_development_dependency) { 'rookie' }

  let :gem do
    Class.new(Jewel::Gem).tap do |gem_class|
      gem_class.name! example_name
      gem_class.summary example_summary
      gem_class.version example_version
      gem_class.homepage example_homepage
      gem_class.license example_license

      gem_class.author example_author
      gem_class.email example_email

      gem_class.files example_files

      gem_class.depend_on example_runtime_dependency

      gem_class.development do
        gem_class.depend_on example_development_dependency
      end
    end
  end

  subject { gem }

  let :hand_written_gem_specification do
    ::Gem::Specification.new 'jewel' do |gem|
      gem.name = example_name.to_s
      gem.summary = example_summary
      gem.version = example_version
      gem.homepage = example_homepage
      gem.license = example_license

      gem.author = example_author
      gem.email = example_email

      gem.files = example_files

      gem.add_runtime_dependency example_runtime_dependency

      gem.add_development_dependency example_development_dependency
    end
  end

  it "'s gem specification should be equivalent to the hand-written one" do
    subject.specification.should == hand_written_gem_specification
  end

end
