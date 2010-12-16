module Redcar
  class AssociatedFile
    # Open the related (rails) view when in controller and vice versa
    class OpenViewControllerCommand < AssociatedCommand
      def execute
        return if remote_project?
        
        self.project_root = Project::Manager.focussed_project.path
        return unless rails_project?
        
        self.file_path    = doc.path.gsub(project_root, "")
        
        # if the doc is a controller, show the view and vice versa
        if path_matcher.is_controller?
          switch_to_view
        elsif path_matcher.is_view?
          switch_to_controller
        end
      end
      
      # open the view from the controller
      def switch_to_view
        unless ( name = path_matcher.controller_name )
          return
        end
        # figure out what the name of def we are in is
        action = find_function_under_cursor
        view   = File.join(project_root, "/app/views/#{name}/#{action}")
        
        # open the according view (most likely non existant)
        if !File.exists?(view)
          %w(erb html.erb haml js.erb xml.erb).each do |try|
            if File.exists?("#{view}.#{try}")
              view += ".#{try}"
              break
            end
          end
        end
        
        open_file view
      end
      
      # open the controller from the view
      def switch_to_controller
        unless ( name = path_matcher.view_name )
          return
        end
        
        action     = File.basename(file_path).split(".").first
        controller = "/app/controllers/#{name}_controller.rb"
        
        goto_definition controller, "def #{action}"
      end
    end
  end
end