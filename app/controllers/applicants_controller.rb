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

        if !skills
            skills = {}
        end
        if !traits
            traits = {}
        end


        

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

    def recruiters
        applicant_id = params[:id]
        applicant = Applicant.find_by(id: applicant_id)
        recruiters = Recruiter.all
        applicants_skills = get_skills_list(applicant)
        print applicants_skills
        if applicants_skills.length > 1
            print "\nlets do applicants_skills\n"
            puts 1
            recruiters_skills = {}
            puts 2
            for recruiter in recruiters do
                puts 3
                recruiters_skills[recruiter.id] = get_skills_list(recruiter)
                puts 4
            end

            for recruiter in recruiters_skills.keys do
                recruiters_skills[recruiter] = recruiters_skills[recruiter] & applicants_skills
            end
            recruiters_skills = recruiters_skills.sort_by { |k, v| v.length }.reverse
            if recruiters_skills[0][0] > 0
                puts "Recruiter chosen"
                print recruiters_skills[0]
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

        if @choice == nil
            puts "\n\n\ndid not choose"
            recruiters_experiance = {}
            puts 2
            for recruiter in recruiters do
                recruiters_experiance[recruiter.id] = recruiter.applicants.length
            end
            recruiters_experiance = recruiters_experiance.sort_by { |k, v| v }.reverse
            puts "\n\n\nrec ex"
            print recruiters_experiance
            
            if recruiters_experiance[0][1] > 0
                puts "Recruiter chosen"
                print recruiters_experiance[0]
                best_id = recruiters_experiance[0][0]
                best = Recruiter.find_by(id: best_id)
                @choice = {
                    id: best_id,
                    on: "experiance",
                    name: best.name + " " + best.surname,
                    applicant_id: applicant_id
                }
            end
        end

        if @choice == nil
            puts "\n\n\ndid not choose"
            offset = rand(Recruiter.count)
            recruiter = Recruiter.offset(offset).first
            @choice = {
                    id: recruiter.id,
                    on: "luck",
                    name: recruiter.name + " " + recruiter.surname,
                    applicant_id: applicant_id
                }
        end

        @options = []
        for r in recruiters do
            @options.push([r.name + " " + r.surname, r.id])
        end

        puts "\n\nAsked to change recruiters"
        respond_to do |format|
            format.html
            format.js
        end

    end

    def update_recruiter
        print params
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

    def applicant_invite
        require 'date'
        puts "\n\n\n Lets invite applicant"
        print params
        date = params[:applicant].values
        meeting_time = DateTime.new(date[0].to_i, date[1].to_i, date[2].to_i, date[3].to_i, date[4].to_i, 0)
        @applicant = Applicant.find_by(id: params[:id])
        recruiter = @applicant.recruiter
        UserMailer.with(applicant: @applicant, recruiter: recruiter, meeting_time: meeting_time).applicant_meeting_email.deliver_now
        UserMailer.with(applicant: @applicant, recruiter: recruiter, meeting_time: meeting_time).recruiter_meeting_email.deliver_now
        
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
