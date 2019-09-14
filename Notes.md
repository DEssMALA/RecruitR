# Data base tables

## Positions
| title: `string` | description: `text` | active: `boolean` |
```
Has many: applicants, skills, traits
```
## Recruiters
| name: `string` | surname: `string` | email: `string` |
```
Has many: applicants, skills
```
## Applicants
| name: `string` | surname: `string` | email: `string` |
```
Has one: position, recruiter
Has many: skills, traits through trait_score
```
## Skills
| name: `string` |
```
Has many: positions, recruiters, applicants
```
## Traits
| name: `string` |
```
Has many: positions, applicants through trait_score
```
## Trait_score
| score: `integer` |
```
Has one: trait, applicant
```
## Users
| name: `string` | surname: `string` | email: `string` | 
```

```



# Guides

* [Rails getting started](https://guides.rubyonrails.org/getting_started.html)
* [Many to Many](https://www.sitepoint.com/master-many-to-many-associations-with-activerecord/) by Fred Heath
