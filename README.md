# Bugzilla
### Basic Requirements

1.  Sign up, login and logout of users(name, email, password, user_type\[developer, manager, qa\])
2.  Manager/user can have many projects
3.  The user can enter many bugs
4.  A bug has a creator(user)
5.  A bug has a developer who\'ll solve the bug(user)
6.  A bug belongs to a project
7.  A project can have many users
8.  A project can have many bugs too.
9.  The bug has a descriptive title and deadline and a screenshot, type, and status
10. Screen shot should be an image either .png or .gif no other type of image is allowed.
11. Description and the screenshot is not compulsory but title, status and type are compulsory.
12. The title of a bug should be unique throughout the project
13. Type can have two values (feature, bug)
14. Status is a drop down having values (new, started, completed) if it\'s a feature or (new, started and resolved) if it\'s a bug.

Use ActiveStorage for file uploads\
Use Pundit Gem for Roles Authorizations.

### Roles:

#### Manager:

1.  Create a Project.
2.  Edit and Delete the projects he creates.
3.  Add/Remove Developers and QAs to the projects he creates.

#### Developer:

1.  Assign bugs to himself. Pick up a bug from the list of his projects.
2.  Can see only the projects he is part of.
3.  Mark a bug resolved.
4.  Can not see other projects.
5.  Can not report Bug.
6.  Can not delete a Bug.
7.  Can not join any project.

### QA:

1.  Report Bugs to all projects. (QAs addition to project is only to gignify that this QA is          mainly responsible for the QA of project, not that he will only report bugs in the project)
2.  Can see all projects.
3.  Can not edit/delete/create any project.


## Stack used
---
Ruby version 2.7.0
Rails Version 5.2.8
Postgres Version 14.2

## Dependencies
---
1. Devise to manage all user's sign ups, logins, password recovery.
2. Bootstrap to style application views and layouts
3. Jquery to handle AJAX calls.
4. Pundit to authorize user roles.
5. Active Storage to store images.
6. Cloudinary to store active storage images to cloud.
7. Kaminari for pagination
8. Rubocop to follow rails best practices and guidlines

## How to run on local machine.
---
Open Termnal and type
```
git clone
```
Then
```
cd Bugzilla
```
Install Gems
```
bundle install
```
Setup DB
```
rails db:create
rails db:migrate
```
Run Server
```
rails s
```
Run
```
localhost:3000
```
