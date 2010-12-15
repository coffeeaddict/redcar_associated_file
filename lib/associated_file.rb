module Redcar
  
  # load associated file (eg spec or test or (rails) view/controller) with a 
  # single keystroke
  #
  # shift-ctrl-a : load view <-> controller
  # shift-ctrl-t : load test/spec <-> lib/model
  # shift-ctrl-y : load test <-> fixture
  class AssociatedFile
    def self.menus
      Menu::Buidler.build do
        sub_menu "File" do
          sub_menu "Associated File" do
            item "Open associated view", OpenViewCommand
            item "Open associated controller", OpenControllerCommand
            item "Open associated test", OpenTestCommand
            item "Open associated class", OpenClassCommand
            item "Open associated fixture", OpenFixtureCommand
          end
        end
      end
    end
    
    def self.keymaps
      linwin = Keymap.build("main", [ :linux, :windows ]) do
        link "Shift+Ctrl+A", AssociatedFile::OpenViewCommand
      end
      osx = Keymap.build("main", :osx) do
        link "Shift+Cmd+A", AssociatedFile::OpenViewCommand
      end
      
      [linwin, osx]
    end
  
    class OpenViewCommand < Command
    end
    
    class OpenControllerCommand < Command; end
    class OpenTestCommand < Command; end
    class OpenClassCommand < Command; end
    class OpenFixtureCommand < Command; end
  end
end