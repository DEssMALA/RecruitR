# RecruitR

Rails app for Human Resources to manage applications, meetings and recruiters.

## Development environment:
* Ruby version: `ruby 2.6.3`
* Rails version: `Rails 5.2.3`

## System description:
There are 3 resources:
* Positions
* Applicants
* Recruiters

Applicants can only be created for specific position. In position skills and traits that are important can be specified. For applicant then it is possible to select skills and grade traits. A recruiter is suggested for applicant based on smart logic. When recruiter is assigned to applicant meeting time can be chosen and emails notifying both participants is sent.

## Installation:
1. `git clone https://github.com/LaiArturs/RecruitR.git`
2. `cd RecruitR`
3. `bundle install`
4. `rake db:create`
5. `rake db:migrate`
6. In order for emails to work you should change email setting in:
    `app\mailers\application_mailer.rb`, `config\credentials.yml.enc`, and `config\environments\production.rb`
7. `rails s`

## Known bugs:
* No tests
* Little validation


