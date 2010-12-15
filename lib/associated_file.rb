module Redcar
  
  # load associated file (eg spec or test or (rails) view/controller) with a 
  # single keystroke
  #
  # shift-ctrl-a : load view <-> controller
  # shift-ctrl-t : load test/spec <-> lib/model
  # shift-ctrl-y : load test <-> fixture
  class AssociatedFile
    CAN_NOT_COMPLY = :can_not_comply
    
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
  
    class AssociatedCommand < EditTabCommand
      # check for remote project and display a dialog if so
      def remote_project?
        # just assuming that this is true
        if Project::Manager.focussed_project.remote?
          Application::Dialog.message_box("Go to declaration doesn't work in remote projects yet :(")
          return true
        end
        
        return false
      end
      
      def log message
        puts "-=-> AF: #{message}"
      end
    end
    
    class OpenViewControllerCommand < AssociatedCommand
      def execute
        return if remote_project?
        
        log doc.inspect
      end  
    end
    
    class OpenControllerCommand < Command; end
    class OpenTestCommand < Command; end
    class OpenClassCommand < Command; end
    class OpenFixtureCommand < Command; end
  end
end