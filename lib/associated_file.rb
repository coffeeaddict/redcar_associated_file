module Redcar
  
  # load associated file (eg spec or test or (rails) view/controller) with a 
  # single keystroke
  #
  # shift-ctrl-a : load view <-> controller
  # shift-ctrl-t : load test/spec <-> lib/model
  # shift-ctrl-y : load test <-> fixture
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
  
    class AssociatedCommand < EditTabCommand
      attr_accessor :project_root, :file_path
      
      # check for remote project and display a dialog if so
      def remote_project?
        # just assuming that this is true
        if Project::Manager.focussed_project.remote?
          Application::Dialog.message_box("Open associated file doesn't work in remote projects yet")
          return true
        end
        
        return false
      end
      
      def rails_project?
        unless ( root = self.project_root )
          log "the project root was not yet defined"
          return false
        end
        
        # first, lets see if the project root is a rails root - else do nothing
        unless (
          File.exists?(File.join(root, "config", "environment.rb")) and
          File.exists?(File.join(root, "config", "boot.rb"))
        )
          log "You don't seem to be in a rails root"
          return false
        end
        
        true
      end
      
      def goto_definition file, definition
        Project::Manager.open_file file
        re = Regexp.new(Regexp.escape(definition))
        
        DocumentSearch::FindNextRegex.new(re,true).run_in_focussed_tab_edit_view
      end
      
      # search backwards for a function definition
      #
      def find_function_under_cursor
        position = doc.cursor_offset
        area = doc.get_all_text[0..position]
        area.reverse!
        
        re = Regexp.new /\n^\s*([\w\&\*\(\)\s]+) fed\s*\n/
        if ( match = area.match(re) )
          return match[1].reverse
        end
      
        nil
      end
      
      def log message
        puts "-=-> AF: #{message}"
      end
    end
    
    # Open the related (rails) view when in controller and vice versa
    class OpenViewControllerCommand < AssociatedCommand
      def execute
        return if remote_project?
        
        self.project_root = Project::Manager.focussed_project.path
        return unless rails_project?
        
        self.file_path    = doc.path.gsub(project_root, "")
        
        # if the doc is a controller, show the view and vice versa
        if file_path =~ /controllers\/\w+_controller.rb/
          switch_to_view
        elsif file_path =~ /\/views\//
          switch_to_controller
        end
      end
      
      # open the view from the controller
      def switch_to_view
        unless ( match = file_path.match(/controllers\/(\w+)_controller.rb/) )
          return
        end
        # figure out what the name of def we are in is
        action = find_function_under_cursor
        view   = File.join(project_root, "/app/views/#{match[1]}/#{action}")
        
        # open the according view (most likely non existant)
        if !File.exists?(view)
          %w(erb html.erb haml js.erb xml.erb).each do |try|
            if File.exists?("#{view}.#{try}")
              view += ".#{try}"
              break
            end
          end
        end
        
        Project::Manager.open_file view if File.exists?(view)
      end
      
      # open the controller from the view
      def switch_to_controller
        unless ( match = file_path.match(/\/views\/([^\/]+)/) )
          return
        end
        
        action     = File.basename(file_path).split(".").first
        controller = File.join(project_root, "/app/controllers/#{match[1]}_controller.rb")        
        
        goto_definition controller, "def #{action}"
      end
    end
    
    class OpenTestClassCommand < AssociatedCommand
      def execute
        return if remote_project?
                
        self.project_root = Project::Manager.focussed_project.path
        self.file_path    = doc.path.gsub(project_root, "")

        if rails_project?
          # if the doc is a controller, show the view and vice versa
          if file_path =~ /controllers\/\w+_controller.rb/
            switch_to_functional
          elsif file_path =~ /test\/functional\/\w+_controller_test/
            switch_to_controller
          elsif file_path =~ /test\/unit\/\w+_test/
            switch_to_model
          end
          
        else
          log "Non rails projects are not implemented yet"
        end
      end
      
      def switch_to_functional
      end
      
      # TODO: We might be able to figure out what action this test belongs to
      #
      def switch_to_controller
        unless ( match = file_path.match(/test\/functional\/(\w+_controller)_test/) )
          return
        end
                
        controller = File.join(project_root, "/app/controllers/#{match[1]}.rb")        
        
        unless File.exists? controller
          log "No such controller"
          return
        end
        
        Project::Manager.open_file controller
      end
      
      def switch_to_model
      end
    end
    
    class OpenTestFixtureCommand < AssociatedCommand
    end
  end
end
