# frozen_string_literal: true

module ControllerMacros
  def login_manager(&proc)
    before do
      @request.env['devise.mapping'] = Devise.mappings[:manager]
      manager_user = proc ? instance_eval(&proc) : FactoryBot.create(:user, user_type: 'manager')
      sign_in manager_user
    end
  end

  def login_developer(&proc)
    before do
      @request.env['devise.mapping'] = Devise.mappings[:developer]
      developer_user = proc ? instance_eval(&proc) : FactoryBot.create(:user, user_type: 'developer')
      # user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the "confirmable" module
      sign_in developer_user
    end
  end

  def login_qa(&proc)
    before do
      @request.env['devise.mapping'] = Devise.mappings[:qa]
      qa_user = proc ? instance_eval(&proc) : FactoryBot.create(:user, user_type: 'qa')
      # user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the "confirmable" module
      sign_in qa_user
    end
  end
end
