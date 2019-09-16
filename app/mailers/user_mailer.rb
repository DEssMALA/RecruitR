class UserMailer < ApplicationMailer

    def applicant_meeting_email
        @applicant = params[:applicant]
        @recruiter = params[:recruiter]
        @meeting_time = params[:meeting_time]

        mail(to: @applicant.email, subject: "Interview for #{@applicant.position.title} scheduled")
    end

    def recruiter_meeting_email
        @applicant = params[:applicant]
        @recruiter = params[:recruiter]
        @meeting_time = params[:meeting_time]
 
        mail(to: @recruiter.email, subject: "Interview for #{@applicant.position.title} scheduled")
    end

end
