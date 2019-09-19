class CalendarApiController < ApplicationController
    

    
    def redirect
        client = Signet::OAuth2::Client.new(client_options)
        redirect_to client.authorization_uri.to_s
    end

    def callback
        client = Signet::OAuth2::Client.new(client_options)
        client.code = params[:code]
    
        response = client.fetch_access_token!
    
        session[:authorization] = response
    
        redirect_to calendars_url
    end

    def calendars
        client = Signet::OAuth2::Client.new(client_options)
        client.update!(session[:authorization])
    
        service = Google::Apis::CalendarV3::CalendarService.new
        service.authorization = client
    
        @calendar_list = service.list_calendar_lists
    
    end

    def events
        client = Signet::OAuth2::Client.new(client_options)
        client.update!(session[:authorization])
    
        service = Google::Apis::CalendarV3::CalendarService.new
        service.authorization = client
    
        @event_list = service.list_events(params[:calendar_id])
    end

    def new_event
        client = Signet::OAuth2::Client.new(client_options)
        client.update!(session[:authorization])
    
        service = Google::Apis::CalendarV3::CalendarService.new
        service.authorization = client
    
        today = Date.today
    
        event = Google::Apis::CalendarV3::Event.new({
          start: Google::Apis::CalendarV3::EventDateTime.new(date: today),
          end: Google::Apis::CalendarV3::EventDateTime.new(date: today + 1),
          summary: 'New event!'
        })
    
        service.insert_event(params[:calendar_id], event)
    
        redirect_to events_url(calendar_id: params[:calendar_id])
    end

    def new_interview
        applicant = Applicant.find_by(id: params[:id])
        dt = applicant.meeting
        start_time = DateTime.civil_from_format(:utc,dt.year,dt.month,dt.day,dt.hour,dt.min)
        end_time = DateTime.civil_from_format(:utc,dt.year,dt.month,dt.day,dt.hour,dt.min) + 1.hour

        client = Signet::OAuth2::Client.new(client_options)
        client.update!(session[:authorization])
        
        service = Google::Apis::CalendarV3::CalendarService.new
        service.authorization = client
    
        event = Google::Apis::CalendarV3::Event.new({
          start: Google::Apis::CalendarV3::EventDateTime.new(date_time: start_time),
          end: Google::Apis::CalendarV3::EventDateTime.new(date_time: end_time),
          summary: "#{applicant.position.title} interview.",
          attendees: [{email: applicant.email}, {email: applicant.recruiter.email}],
          sendNotifications: true
        })
    
        service.insert_event('recruitr47@gmail.com', event,send_notifications: true)
        redirect_to "/applicants/#{applicant[:id]}"
        rescue Google::Apis::AuthorizationError
            response = client.refresh!
        
            session[:authorization] = session[:authorization].merge(response)
        retry    
    end

    private
    def client_options
        {
        client_id: Rails.application.credentials.dig(:google_api)[:client_id],
        client_secret: Rails.application.credentials.dig(:google_api)[:client_secret],
        authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
        token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
        scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
        redirect_uri: callback_url
        }
    end
    
end
