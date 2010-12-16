# vendor in active support
$: << File.expand_path('../vendor/activesupport-3.0.3/lib', __FILE__)

require 'active_support'
require 'active_support/inflector/inflections'
require 'active_support/inflections'

require 'associated_file/association_matcher'
require 'associated_file/associated_command'
require 'associated_file/open_view_controller_command'
require 'associated_file/open_test_class_command'
require 'associated_file/open_test_fixture_command'

class String
  def singularize
    ActiveSupport::Inflector.singularize self
  end
  def pluralize
    ActiveSupport::Inflector.pluralize self
  end
end

module Redcar
  
  # load associated file (eg spec or test or (rails) view/controller) with a 
  # single keystroke
  #
  # shift-ctrl-a : load view <-> controller
  # shift-ctrl-t : load test/spec <-> lib/model
  # shift-ctrl-y : load test <-> fixture
  #
  class AssociatedFile    
    def self.menus
      Menu::Builder.build do
        sub_menu "Project" do
          sub_menu "Associated File" do
            item "Open associated view/controller", OpenViewControllerCommand
            item "Open associated test/class", OpenTestClassCommand            
            item "Open associated test/fixture", OpenTestFixtureCommand
          end
        end
      end
    end
    
    def self.keymaps
      linwin = Keymap.build("main", [ :linux, :windows ]) do
        link "Shift+Ctrl+A", AssociatedFile::OpenViewControllerCommand
        link "Shift+Ctrl+T", AssociatedFile::OpenTestClassCommand
        link "Shift+Ctrl+Y", AssociatedFile::OpenTestFixtureCommand
      end
      osx = Keymap.build("main", :osx) do
        link "Shift+Cmd+A", AssociatedFile::OpenViewControllerCommand
        link "Shift+Cmd+T", AssociatedFile::OpenTestClassCommand
        link "Shift+Cmd+Y", AssociatedFile::OpenTestFixtureCommand
      end
      
      [linwin, osx]
    end    
  end
end
