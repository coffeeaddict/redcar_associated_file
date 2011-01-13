module Redcar
  class AssociatedFile
    
    # open:
    # * controller <-> functional test
    # * model      <-> unit test
    # * fixture    --> unit text
    #
    class OpenTestClassCommand < AssociatedCommand
      def execute
        return if remote_project?
                
        self.project_root = Project::Manager.focussed_project.path
        self.file_path    = doc.path.gsub(project_root, "")

        if rails_project?
          # if the doc is a controller, show the view and vice versa
          if path_matcher.is_controller?
            switch_to_functional
            
          elsif path_matcher.is_view?
            switch_to_functional
            
          elsif path_matcher.is_functional?
            switch_to_controller
            
          elsif path_matcher.is_unit?
            switch_to_model
            
          elsif path_matcher.is_model?
            switch_to_unit
            
          elsif path_matcher.is_fixture?
            switch_to_unit
            
          end
          
        else
          log "Non rails projects are not implemented yet"
        end
      end
      
      # open the functional test and try to find a test for the current 
      # function based on the function name
      #
      def switch_to_functional
        return unless ( 
          name = path_matcher.controller_name || path_matcher.view_name
        )
        
        test_file = "/test/functional/#{name}_test.rb"
        if !file_exists? test_file
          test_file = "/test/functional/#{name}_controller_test.rb"
        end
        
        if path_matcher.is_view?
          action = File.basename(file_path).split(".").first
          regexp = Regexp.new(action)
          
          candidates = get_tests(test_file).select { |t| t =~ regexp }        
          
          if candidates.length > 0
            log "Jumping to #{test_file}##{candidates.first}"
            return goto_definition test_file, candidates.first
          end
          
        elsif ( function = find_function_under_cursor )
          # select a candidate to jump tp
          regexp = Regexp.new(function)
          candidates = get_tests(test_file).select { |t| t =~ regexp }        
          
          if candidates.length > 0
            log "Jumping to #{test_file}##{candidates.first}"
            return goto_definition test_file, candidates.first
          end          
        end
        
        open_file test_file
      end
      
      # open the controller that belongs to this functional test.
      #
      # Try to find a function based on 
      def switch_to_controller
        return unless ( name = path_matcher.functional_name )
        
        controller = "/app/controllers/#{name}.rb"
        
        if (test = find_test_under_cursor)        
          # remove words from the test name that indicate the test
          # then use the first word as the name of the function/action
          #
          test.sub!(/^should /i, '')
          if test =~ /^(get|post|put|delete) /i
            test.sub!(/^[^\s]+ /, '')
          end
          
          function = test.split(/\s/).first
          unless function.nil?
            return goto_definition(controller, function)
          end
        end
        
        open_file controller
      end
      
      def switch_to_model
        unless ( name = path_matcher.unit_name )
          return
        end
        
        open_file "/app/models/#{name}.rb"        
      end
      
      # switch to the unit test file and select a unit test that has a name
      # similar to the name of the function under cursor
      #
      def switch_to_unit
        unless ( name = (path_matcher.model_name || path_matcher.fixture_name) )
          return
        end
        
        test_file = "/test/unit/#{name}_test.rb"
        if path_matcher.is_fixture?          
          test_file = "/test/unit/#{name.singularize}_test.rb"
          
        elsif ( function = find_function_under_cursor )
          function.gsub! '_', ' '
          log "Looking for a test with '#{function}'"
          regexp = Regexp.new(function)
          
          candidates = get_tests(test_file).select { |t| t =~ regexp }
          if candidates.length > 0
            return goto_definition test_file, candidates.first
          end
        end
          
        open_file test_file
      end
      
      
      # get all the test names from a file
      #
      def get_tests file
        return [] if !file_exists? file
        contents = File.read(project_file(file))
        contents.scan(/test [\'\"]([^\'\"]+)[\'\"] do/).flatten
      end
      
      private :get_tests
    end
  end
end