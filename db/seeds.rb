# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
manager = User.new(
  email: 'user1@example.com',
  password: 'password',
  password_confirmation: 'password',
  name: 'User 1',
  user_type: 'manager'
)
manager.skip_confirmation!
manager.save!

developer = User.new(
  email: 'user2@example.com',
  password: 'password',
  password_confirmation: 'password',
  name: 'User 2',
  user_type: 'developer'
)
developer.skip_confirmation!
developer.save!

qa = User.new(
  email: 'user3@example.com',
  password: 'password',
  password_confirmation: 'password',
  name: 'User 3',
  user_type: 'qa'
)
qa.skip_confirmation!
qa.save!

manager.projects.create!({ title: 'Demo Project 1', description: 'This is demo project 1' },
                         { title: 'Demo Project 2', description: 'This is demo project 2' },
                         { title: 'Demo Project 3', description: 'This is demo project 3' },
                         { title: 'Demo Project 4', description: 'This is demo project 4' },
                         { title: 'Demo Project 5', description: 'This is demo project 5' },
                         { title: 'Demo Project 6', description: 'This is demo project 6' })

qa.bugs_created.create!({ title: 'Dummy Bug 1', description: 'This is dummy bug 1',
                          bug_type: 'feature', deadline: Time.now.utc + 20.days, project_id: 1, developer: developer },
                        { title: 'Dummy Bug 2', description: 'This is dummy bug 2',
                          bug_type: 'bug', deadline: Time.now.utc + 20.days, project_id: 2 },
                        { title: 'Dummy Bug 3', description: 'This is dummy bug 3',
                          bug_type: 'bug', deadline: Time.now.utc + 20.days, project_id: 3, developer: developer },
                        { title: 'Dummy Bug 4', description: 'This is dummy bug 4',
                          bug_type: 'feature', deadline: Time.now.utc + 20.days, project_id: 4 },
                        { title: 'Dummy Bug 5', description: 'This is dummy bug 5',
                          bug_type: 'feature', deadline: Time.now.utc + 20.days, project_id: 5, developer: developer })
