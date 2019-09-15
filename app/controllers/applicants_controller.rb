class ApplicantsController < ApplicationController

    def index
        @applicants = Applicant.all
    end

    def show
        @applicant = Applicant.find_by(id: params[:id])
    end

    def new
        position_id = params[:id]
        puts "\n\nRequested to fill new applicants form for position: #{position_id}\n"
        @position = Position.find(params[:id])
    end
        
    def edit
        @applicant = Applicant.find_by(id: params[:id])
        @position = Position.find_by(id: @applicant.position.id)
    end

    def create
        puts "\n\nPOST to create new applicant \n"
        print params

        @position = Position.find_by(id: params[:id])

        # Retrieve status of skills and traits from form
        skills = params[:skills]
        traits = params[:traits]
        puts "\n\nSkils and Traits"
        print skills
        print traits


        

        # Check if there is such position (for security)
        if @position
            request_params = params
            params = ActionController::Parameters.new({
                applicant: {
                    name: request_params[:name],
                    surname: request_params[:surname],
                    email: request_params[:user][:address],
                    position_id: @position.id
                }
            })

            @applicant = Applicant.new(applicant_params(params))

            if @applicant.save            
                puts "\n\n Applicant"
                print @applicant
                print @applicant[:id]
                
                # Add skills to applicant
                for s in skills.keys do
                    if skills[s] == "1"
                        skill = Skill.find_or_create_by(name: s)
                        @applicant.skills << skill
                    end
                end

                # Add traits to applicant
                for t in traits.keys do
                    trait = Trait.find_or_create_by(name: t)
                    TraitScore.create score: traits[t].to_i, applicant: @applicant, trait: trait
                end
                
                redirect_to "/applicants/#{@applicant[:id]}"
            else
                render "new"
            end     
        end
    end

    def update
        puts "\n\nUpdating Applicant"
        print params
        @applicant = Applicant.find_by(id: params[:id])
        new_skills = params[:skills]
        new_traits = params[:traits]
        puts "\n\nNew skilss and traits:"
        print new_skills
        print new_traits

        # Delete current applicant skills
        @applicant.skills.clear
        # Add new skills
        for s in new_skills.keys do
            skill = Skill.find_or_create_by(name: s)
            @applicant.skills << skill
        end

        # Delete current applicant traits
        @applicant.traits.clear
        # Add traits to applicant
        for t in new_traits.keys do
            trait = Trait.find_or_create_by(name: t)
            TraitScore.create score: new_traits[t].to_i, applicant: @applicant, trait: trait
        end

        if @applicant.update(applicant_params(params))
            redirect_to "/applicants/#{@applicant[:id]}"
        else
            render 'edit'
        end
        
    end

    def destroy
        puts "\n\n Call for Destroy"
        print params 
        @applicant = Applicant.find(params[:id])
        @applicant.destroy
    
        redirect_to "/applicants"
    end

    def positions
        position_id = params[:id]
        @position = Position.find_by(id: position_id)
        @applicants = @position.applicants
        @skills = {}
        for applicant in @applicants do
            @skills[applicant[:id]] = []
            for skill in applicant.skills do
                @skills[applicant[:id]].push(skill.name)
            end
        end
        puts "\n\n   Position applicants"
        print position_id
    end

    private
        # Check that parameters contains only allowed values.
        def applicant_params (params)
            params.require(:applicant).permit(:name, :surname, :email, :position_id)
        end
end
