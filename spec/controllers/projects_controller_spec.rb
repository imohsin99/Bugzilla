# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do
  let(:manager) { create :user, :manager }
  let(:developer) { create :user, :developer }
  let(:project) { create :project, manager: manager }

  before do
    sign_in manager
    project.assigned_users << developer
  end

  RSpec.shared_examples 'record not found' do
    it 'request should be unsuccessful' do
      expect(response).not_to be_successful
    end

    it { is_expected.to rescue_from(ActiveRecord::RecordNotFound).with(:record_not_found) }
  end

  RSpec.shared_examples 'unauthorized user' do
    it { is_expected.to rescue_from(Pundit::NotAuthorizedError).with(:user_not_authorized) }
  end

  context 'with before_actions' do
    it { is_expected.to use_before_action(:set_projects) }
  end

  context 'with after_actions' do
    it { is_expected.to use_after_action(:verify_authorized) }
    it { is_expected.to use_after_action(:verify_policy_scoped) }
  end

  context 'with routes' do
    it { is_expected.to route(:get, '/projects').to(action: :index) }
    it { is_expected.to route(:get, '/projects/1').to(action: :show, id: 1) }
    it { is_expected.to route(:get, '/projects/new').to(action: :new) }
    it { is_expected.to route(:post, '/projects').to(action: :create) }
    it { is_expected.to route(:get, '/projects/1/edit').to(action: :edit, id: 1) }
    it { is_expected.to route(:put, '/projects/1').to(action: :update, id: 1) }
    it { is_expected.to route(:patch, '/projects/1').to(action: :update, id: 1) }
    it { is_expected.to route(:delete, '/projects/1').to(action: :destroy, id: 1) }
  end

  describe 'GET #index' do
    RSpec.shared_examples 'index successfull' do
      it 'returns a successful response' do
        expect(response).to be_successful
      end

      it 'renders the index template' do
        expect(response).to render_template(:index)
      end

      it 'assigns @projects' do
        expect(assigns(:projects)).to include(project)
      end
    end

    context 'when manager requests index' do
      before { get :index }

      include_examples 'index successfull'
    end

    context 'when qa requests index' do
      login_qa

      before do
        get :index
      end

      include_examples 'index successfull'
    end

    context 'when developer requests index' do
      before do
        sign_in developer
        get :index
      end

      include_examples 'index successfull'
    end
  end

  describe 'GET #show' do
    RSpec.shared_examples 'show successfull' do
      it 'have http status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'return the project' do
        expect(assigns(:project)).to eq(project)
      end

      it 'respond with show' do
        expect(response).to render_template(:show)
      end
    end

    context 'when manager requests project show' do
      before do
        get :show, params: { id: project.id }
      end

      include_examples 'show successfull'
    end

    context 'when qa requests project show' do
      login_qa
      before do
        get :show, params: { id: project.id }
      end

      include_examples 'show successfull'
    end

    context 'when developer requests project show' do
      before do
        sign_in developer
        get :show, params: { id: project.id }
      end

      include_examples 'show successfull'
    end

    context 'when requesting invalid project' do
      before { get :show, params: { id: 0 } }

      include_examples 'record not found'
    end

    context 'when user is unauthorized' do
      login_developer

      before do
        get :show, params: { id: project.id }
      end

      include_examples 'unauthorized user'
    end
  end

  describe 'GET #new' do
    context 'with new project' do
      before { get :new }

      it 'have http status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'respond with new' do
        expect(response).to render_template(:new)
      end

      it 'assign a @project' do
        expect(assigns(:project)).not_to be_nil
      end
    end

    context 'when user is unauthorized' do
      login_developer

      before { get :new }

      include_examples 'unauthorized user'
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      before do
        post :create, params: {
          project: attributes_for(:project)
        }
      end

      it 'assign a value to @project' do
        expect(assigns(:project)).not_to be_nil
      end

      it 'create a project and redirect to the projects' do
        expect(response).to redirect_to projects_path
      end

      it 'create a project and increment count' do
        expect do
          post :create, params: {
            project: attributes_for(:project), id: project.id
          }
        end.to change(Project, :count).by(1)
      end

      it { is_expected.to set_flash[:notice].to(I18n.t('project_added')) }
    end

    context 'with invalid attributes' do
      before do
        post :create, params: { project: { title: nil }, id: project.id }
      end

      it 'does not create project and render' do
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    context 'when editing existing project' do
      before do
        get :edit, params: {
          id: project.id
        }
      end

      it 'http status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'respond with edit' do
        expect(response).to render_template(:edit)
      end

      it 'return the project' do
        expect(assigns(:project)).to eq(project)
      end
    end

    context 'when requesting invalid project' do
      before do
        get :edit, params: {
          id: 0
        }
      end

      include_examples 'record not found'
    end

    context 'when user is unauthorized' do
      login_developer

      before do
        get :edit, params: {
          id: project.id
        }
      end

      include_examples 'unauthorized user'
    end
  end

  describe 'POST #update' do
    context 'when updating project' do
      before do
        patch :update, params: {
          project: {
            title: 'Updated project',
            description: 'lorem ispum updated'
          },
          id: project.id
        }
      end

      it 'check if updated title' do
        expect(project).to be_saved_change_to_title
      end

      it 'update project and redirect to project' do
        expect(response).to redirect_to projects_path
      end

      it 'return the project' do
        expect(assigns(:project)).to eq(project)
      end

      it { is_expected.to set_flash[:notice].to(I18n.t('project_updated')) }
    end

    context 'when updating project with invalid attributes' do
      before { patch :update, params: { project: { title: nil }, id: project.id } }

      it 'does not update product and render' do
        expect(response).to render_template('edit')
      end
    end

    context 'when requesting invalid project' do
      before do
        patch :update, params: {
          project: {
            title: 'Updated project',
            description: 'lorem ispum updated'
          },
          id: 0
        }
      end

      include_examples 'record not found'
    end
  end

  describe 'DELETE #destroy' do
    context 'when deleting bug' do
      it 'changes count' do
        expect do
          delete :destroy, params: { id: project.id }
        end.to change(Project, :count).by(-1)
      end
    end

    context 'when deleting valid project' do
      before { delete :destroy, params: { id: project.id } }

      it 'deletes project and redirect' do
        expect(response).to redirect_to projects_path
      end

      it 'return the project' do
        expect(assigns(:project)).to eq(project)
      end

      it { is_expected.to set_flash[:notice].to(I18n.t('project_deleted')) }
    end

    context 'when deleting invalid project' do
      before do
        allow_any_instance_of(Project).to receive(:destroy).and_return(false)
        delete :destroy, params: { id: project.id }
      end

      it 'does not change count' do
        expect { delete :destroy, params: { id: project.id } }.not_to change(Project, :count)
      end

      it 'renders template' do
        expect(response).to render_template(:index)
      end

      it { is_expected.to set_flash[:alert].to(I18n.t('project_not_deleted')) }
    end

    context 'when requesting invalid project' do
      before { delete :destroy, params: { id: 0 } }

      include_examples 'record not found'
    end

    context 'when user is unauthorized' do
      login_developer

      before { delete :destroy, params: { id: project.id } }

      include_examples 'unauthorized user'
    end
  end

  describe 'DELETE #remove_user' do
    let(:user) { create :user, :developer }
    let(:assignment) { Assignment.create(user: user, project: project) }

    context 'when removing user from project' do
      before do
        delete :remove_user, params: { project_id: project.id, id: assignment.id }
      end

      it 'redirect to project' do
        expect(response).to redirect_to project
      end

      it 'return the project' do
        expect(assigns(:project)).to eq(project)
      end

      it 'remove user successfull' do
        expect(project.assigned_users).not_to include(user)
      end
    end

    context 'when deleting invalid user assignment' do
      it 'deletion fails' do
        allow_any_instance_of(Assignment).to receive(:destroy).and_return(false)
        delete :remove_user, params: { project_id: project.id, id: assignment.id }
        expect(response).to render_template(:show)
      end

      it 'does not change count' do
        expect do
          delete :remove_user, params: { project_id: project.id, id: assignment.id }
        end.not_to change(project.assignments, :count)
      end
    end

    context 'when user is unauthorized' do
      login_developer

      before do
        delete :remove_user, params: { project_id: project.id, id: assignment.id }
      end

      include_examples 'unauthorized user'
    end
  end
end
