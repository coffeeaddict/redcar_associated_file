module Redcar
  class AssociatedFile
    if !const_defined? :ASSOCIATIONS
      ASSOCIATIONS = {        
        :model      => /\/models\/([\w\/]+).rb$/,
        :view       => /\/views\/([\w\/]+)\/[^\/]+$/,
        :controller => /\/controllers\/([\w\/]+)_controller.rb$/,
        
        :functional => /test\/functional\/(\w+_controller)_(test|spec)/,
        :unit       => /test\/unit\/(\w+)_(test|spec)/,
        :fixture    => /test\/fixtures\/(\w+).yml$/i          
      }      
    end
    
    # match a file to it's associated function
    class AssociationMatcher
      attr_reader :file_path
            
      def initialize file_path
        @file_path = file_path
      end
      
      # take a set of definitions and do some hard-core meta-programming
      def self.setup_for associations={}
        associations.each do |function, regex|
          instance_eval do
            name  = "#{function}_name".to_sym
            is_it = "is_#{function}?".to_sym
            
            define_method name do
              if ( match = self.file_path.match(regex) )                
                return match[1].downcase
              end
              nil
            end
            
            define_method is_it do
              self.send(name).nil? ? false : true
            end
          end
        end
      end

      setup_for ASSOCIATIONS
      
    end
  end
end