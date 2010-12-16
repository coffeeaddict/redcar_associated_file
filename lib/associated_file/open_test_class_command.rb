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
      
      def switch_to_functional
        return unless ( name = path_matcher.controller_name )
                
        open_file "/test/functional/#{name}_test.rb"        
      end
      
      # TODO: We might be able to figure out what action this test belongs to
      #
      def switch_to_controller
        return unless ( name = path_matcher.functional_name )
                
        open_file "/app/controllers/#{name}.rb"        
      end
      
      def switch_to_model
        unless ( name = path_matcher.unit_name )
          return
        end
        
        open_file "/app/models/#{name}.rb"        
      end
      
      def switch_to_unit
        unless ( name = (path_matcher.model_name || path_matcher.fixture_name) )
          return
        end
        
        name = name.singularize if path_matcher.is_fixture?
        
        open_file "/test/unit/#{name}_test.rb"        
      end
    end
  end
end