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
      attr_accessor :file_path, :project_root
      
      # check for remote project and display a dialog if so
      def remote_project?
        # just assuming that this is true
        if Project::Manager.focussed_project.remote?
          Application::Dialog.message_box("Go to declaration doesn't work in remote projects yet :(")
          return true
        end
        
        return false
      end
      
      def goto_definition file, definition
        Project::Manager.open_file file
        re = Regexp.new(Regexp.escape(definition))
        
        DocumentSearch::FindNextRegex.new(re,true).run_in_focussed_tab_edit_view
      end
      
      def log message
        puts "-=-> AF: #{message}"
      end
    end
    
    # Open the related (rails) view when in controller and vice versa
    class OpenViewControllerCommand < AssociatedCommand
      
      def execute
        return if remote_project?
        
        root = Project::Manager.focussed_project.path
        # first, lets see if the project root is a rails root - else do nothing
        unless (
          File.exists?(File.join(root, "config", "environment.rb")) and
          File.exists?(File.join(root, "config", "boot.rb"))
        )
          log "You don't seem to be in a rails root"
          return
        end
        
        self.project_root = root
        self.file_path    = doc.path.gsub!(root, "")
        
        # if the doc is a controller, show the view and vice versa
        if file_path =~ /controllers\/\w+_controller.rb/
          switch_to_view
        elsif file_path =~ /\/views\//
          switch_to_controller
        end
      end
      
      def switch_to_view
      end
      
      # open the controller 
      def switch_to_controller
        unless ( match = self.file_path.match(/\/views\/([^\/]+)/) )
          return
        end
        action     = File.basename(self.file_path).split(".").first
        name       = match[1]
        controller = File.join(self.project_root, "/app/controllers/#{name}_controller.rb")
        
        definition = "def #{action}"
        
        goto_definition(controller, definition)
      end
    end
    
    class OpenTestClassCommand < AssociatedCommand; end    
    class OpenTestFixtureCommand < AssociatedCommand; end
  end
end