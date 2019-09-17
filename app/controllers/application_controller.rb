class ApplicationController < ActionController::Base

    protect_from_forgery with: :exception
    before_action :authenticate_user!, except: [:show, :index, :positions]

    protected
        def listify_from_string (text)
            if text && text.length
            text.downcase!
            text.gsub! ', ', ','
            list = text.split(",")
            else
            list = []
            end
        end

         # Use to assign skills or traits to position
        def add_associations (table, list, data_object)
            for i in list do
            item = table.find_or_create_by(name: i)
            if table == Skill
                data_object.skills << item
            elsif table == Trait
                data_object.traits << item
            end
            end
        end

        def get_skills_list (data_object)
            @skills = []
            for s in data_object.skills do
              @skills.push(s.name)
            end
            return @skills
          end

end
