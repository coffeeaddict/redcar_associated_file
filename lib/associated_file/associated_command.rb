module Redcar
  class AssociatedFile
    
    # Extends edittab command and provides generic behaviour for associated 
    # file commands
    #
    class AssociatedCommand < EditTabCommand
      attr_accessor :project_root, :path_matcher
      attr_reader :file_path
      
      # do the setting of file path, it will create a new AssociationMatcher
      #
      def file_path= file_path
        @file_path = file_path
        
        self.path_matcher = AssociationMatcher.new(@file_path)
        
        @file_path
      end
      
      # check for remote project and display a warning dialog if so
      #
      def remote_project?
        # just assuming that this is true
        if Project::Manager.focussed_project.remote?
          Application::Dialog.message_box(
            "Open associated file doesn't work in remote projects yet"
          )
          return true
        end
        
        return false
      end
      
      # check if this is a rails project by looking for config/environment 
      # and config/boot
      #
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
      
      # open a file with the project manager
      #
      def open_file file
        if !file.include? project_root
          file = File.join(project_root, file)
        end
        
        return(Project::Manager.open_file(file)) if File.exists?(file)
        log "No such file: #{file}"
      end
      
      # open a file and find the definition by regex
      #
      def goto_definition file, definition
        open_file file
        re = Regexp.new(Regexp.escape(definition))
        
        DocumentSearch::FindNextRegex.new(re,true).run_in_focussed_tab_edit_view
      end
      
      # search backwards for a function definition
      #
      def find_function_under_cursor
        position = doc.cursor_offset
        area = doc.get_all_text[0..position]
        area.reverse!
        
        function = Regexp.new /\n^\s*([\w\&\*\(\)\s\=\[\]\{\}\,\:\'\"]+) fed\s*\n/        
        if ( match = area.match(function) )
          return match[1].reverse
        end
      
        nil
      end
      
      # search backwards for the definition of a test
      def find_test_under_cursor
        position = doc.cursor_offset
        area = doc.get_all_text[0..position]
        area.reverse!
        
        test = Regexp.new /\n^\s*[\"\']([^\"\']+)[\"\']\s*tset\s*\n/
        if ( match = area.match(test) )
          return match[1].reverse
        end
      end
      
      def log message
        puts "-=-> AF: #{message}"
      end
    end
    
  end
end