class RecruitersController < ApplicationController

    def index
        @recruiters = Recruiter.all
    end

    def show
        @recruiter = Recruiter.find_by(id: params[:id])
    end
    
    def new
        @recruiter = Recruiter.new
    end

    def edit
        @recruiter = Recruiter.find_by(id: params[:id])
        @skills = get_skills_list(@recruiter)
    end

    def create

        # Saving new position
        @recruiter = Recruiter.new(recruiter_params)
        if @recruiter.save
            # Get array of skills
            skills = listify_from_string(params[:skills])
            # Put skills in db and associate to recruiter
            add_associations(Skill, skills, @recruiter)
            
            redirect_to @recruiter
        else
            render 'new'
        end
    end

    def update
        @recruiter = Recruiter.find_by(id: params[:id])

        current_skills = get_skills_list(@recruiter)
        new_skills = listify_from_string(params[:skills])

        if @recruiter.update(recruiter_params)
            if current_skills != new_skills
                # Remove all skills from this recruiter
                @recruiter.skills.clear
                # Put skills in db and associate to recruiter
                add_associations(Skill, new_skills, @recruiter)
            end
            redirect_to @recruiter
        else
            render 'edit'
        end
    end

    def destroy
        @recruiter = Recruiter.find(params[:id])
        @recruiter.destroy
    
        redirect_to recruiters_path
      end

    private
        # Check that parameters contains only allowed values.
        def recruiter_params
            params.require(:recruiter).permit(:name, :surname, :email)
        end

end
