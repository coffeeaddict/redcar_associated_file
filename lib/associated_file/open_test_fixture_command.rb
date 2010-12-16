module Redcar
  class AssociatedFile
    class OpenTestFixtureCommand < AssociatedCommand
      def execute
        return if remote_project?
                
        self.project_root = Project::Manager.focussed_project.path
        self.file_path    = doc.path.gsub(project_root, "")

        unless rails_project?
          log "non rails projects are not implemented yet"
          return
        end
        
        if path_matcher.is_fixture?
          switch_to_unit
        
        elsif path_matcher.is_unit?
          switch_to_fixture
          
        end
      end
      
      def switch_to_fixture
        return unless ( name = path_matcher.unit_name )        
        
        name = name.pluralize
        open_file "/test/fixtures/#{name}.yml"
      end
      
      def switch_to_unit
        return unless ( name = path_matcher.fixture_name )
        name = name.singularize
        open_file "/test/unit/#{name}_test.rb"
      end
    end
  end
end