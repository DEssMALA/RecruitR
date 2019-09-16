class UserMailer < ApplicationMailer

    # Email to notify applicant about interview time
    def applicant_meeting_email
        @applicant = params[:applicant]
        @recruiter = params[:recruiter]
        @meeting_time = params[:meeting_time]

        mail(to: @applicant.email, subject: "Interview for #{@applicant.position.title} scheduled")
    end

    # Email to notify recruiter about interview time
    def recruiter_meeting_email
        @applicant = params[:applicant]
        @recruiter = params[:recruiter]
        @meeting_time = params[:meeting_time]
 
        mail(to: @recruiter.email, subject: "Interview for #{@applicant.position.title} scheduled")
    end

end
