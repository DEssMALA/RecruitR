class ApplicantsController < ApplicationController

    def index
        @applicants = Applicant.all
    end

    def show
        @applicant = Applicant.find_by(id: params[:id])
    end

    # Applicant is by default assigned to specific position
    def new
        position_id = params[:id]
        @position = Position.find(params[:id])
    end
    
    def edit
        @applicant = Applicant.find_by(id: params[:id])
        @position = Position.find_by(id: @applicant.position.id)
    end

    def create
        @position = Position.find_by(id: params[:id])

        # Retrieve status of skills and traits from form
        skills = params[:skills]
        traits = params[:traits]

        # If skills was not submitted make the hash anyway
        if !skills
            skills = {}
        end
        if !traits
            traits = {}
        end

        # Check if there is such position (for security)
        if @position
            # Hold parameters to submit to DB
            applicant_parameters = ActionController::Parameters.new({
                applicant: {
                    name: params[:name],
                    surname: params[:surname],
                    email: params[:user][:address],
                    position_id: @position.id
                }
            })

            @applicant = Applicant.new(applicant_params(applicant_parameters))
            if @applicant.save            
               
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

        @applicant = Applicant.find_by(id: params[:id])
        new_skills = params[:skills]
        new_traits = params[:traits]

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
        @applicant = Applicant.find(params[:id])
        @applicant.destroy
    
        redirect_to "/applicants"
    end

    # Show all applications for specific position
    def positions
        position_id = params[:id]
        @position = Position.find_by(id: position_id)
        @applicants = @position.applicants
        
        # Arrange applicant skills for easier use in view
        @skills = {}
        for applicant in @applicants do
            @skills[applicant[:id]] = []
            for skill in applicant.skills do
                @skills[applicant[:id]].push(skill.name)
            end
        end
    end

    # Logic for suggesting recruiters for applicants
    def recruiters
        applicant_id = params[:id]
        applicant = Applicant.find_by(id: applicant_id)
        recruiters = Recruiter.all

        # First, see if can establish match with skills
        applicants_skills = get_skills_list(applicant)
        if applicants_skills.length > 1

            # Make nice hash with recruiter skills
            recruiters_skills = {}
            for recruiter in recruiters do
                recruiters_skills[recruiter.id] = get_skills_list(recruiter)
            end

            # Determine applicant and recruiter skill intersection
            for recruiter in recruiters_skills.keys do
                recruiters_skills[recruiter] = recruiters_skills[recruiter] & applicants_skills
            end
            recruiters_skills = recruiters_skills.sort_by { |k, v| v.length }.reverse
            
            # No overlapping skills means no match
            if recruiters_skills[0][0] > 0

                best_id = recruiters_skills[0][0]
                best = Recruiter.find_by(id: best_id)
                @choice = {
                    id: best_id,
                    on: "skills",
                    name: best.name + " " + best.surname,
                    applicant_id: applicant_id
                }
            end
        end

        # If skills did not match, see who has most experience
        # by comparing number of applicants linked to recruiter
        if @choice == nil

            # Get the hash with applicant count for each recruiter
            recruiters_experience = {}
            for recruiter in recruiters do
                recruiters_experience[recruiter.id] = recruiter.applicants.length
            end
            recruiters_experience = recruiters_experience.sort_by { |k, v| v }.reverse
            
            # Chose highest if it has at least one applicant linked to it
            if recruiters_experience[0][1] > 0

                best_id = recruiters_experience[0][0]
                best = Recruiter.find_by(id: best_id)
                @choice = {
                    id: best_id,
                    on: "experience",
                    name: best.name + " " + best.surname,
                    applicant_id: applicant_id
                }
            end
        end

        # If boot previous logic did not return match,
        # choose recruiter randomly
        if @choice == nil
            offset = rand(Recruiter.count)
            recruiter = Recruiter.offset(offset).first
            @choice = {
                    id: recruiter.id,
                    on: "luck",
                    name: recruiter.name + " " + recruiter.surname,
                    applicant_id: applicant_id
                }
        end

        # Get all recruiter for option to chose
        @options = []
        for r in recruiters do
            @options.push([r.name + " " + r.surname, r.id])
        end

        # For Modal
        respond_to do |format|
            format.html
            format.js
        end

    end

    # Save recruiter for applicant
    def update_recruiter
        @applicant = Applicant.find_by(id: params[:id])
        recruiter = Recruiter.find_by(id: params[:chosen_recruiter])

        params = ActionController::Parameters.new({
                applicant: {
                    recruiter_id: recruiter.id
                }
            })
        @applicant.update(applicant_params(params))
        redirect_to "/applicants/#{@applicant[:id]}"

    end

    # When interview date and time is chosen send
    # send email invitations and save the date-time
    def applicant_invite
        require 'date'  # For DateTime.new
        
        # Create Date time value
        date = params[:applicant].values
        meeting_time = DateTime.new(date[0].to_i, date[1].to_i, date[2].to_i, date[3].to_i, date[4].to_i, 0)
        
        @applicant = Applicant.find_by(id: params[:id])
        recruiter = @applicant.recruiter
        
        # Send emails
        UserMailer.with(applicant: @applicant, recruiter: recruiter, meeting_time: meeting_time).applicant_meeting_email.deliver_now
        UserMailer.with(applicant: @applicant, recruiter: recruiter, meeting_time: meeting_time).recruiter_meeting_email.deliver_now
        
        # Save meeting time and return
        params = ActionController::Parameters.new({
                applicant: {
                    meeting: meeting_time
                }
            })
        @applicant.update(applicant_params(params))
        redirect_to "/applicants/#{@applicant[:id]}"
    end


    private
        # Check that parameters contains only allowed values.
        def applicant_params (params)
            params.require(:applicant).permit(:name, :surname, :email, :position_id, :recruiter_id, :meeting)
        end
end
