# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BugsController, type: :controller do
  let(:qa) { create :user, :qa }
  let(:manager) { create :user, :manager }
  let(:developer) { create :user, :developer }
  let(:project) { create :project, manager: manager }
  let(:bug) { create :bug, project: project, creator: qa, developer: developer }

  before do
    sign_in bug.creator
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
    it { is_expected.to use_before_action(:set_project) }
    it { is_expected.to use_before_action(:set_bug) }
  end

  context 'with after_actions' do
    it { is_expected.to use_after_action(:verify_authorized) }
  end

  context 'with routes' do
    it { is_expected.to route(:get, '/projects/1/bugs').to(action: :index, project_id: 1) }
    it { is_expected.to route(:get, '/projects/1/bugs/1').to(action: :show, project_id: 1, id: 1) }
    it { is_expected.to route(:get, '/projects/1/bugs/new').to(action: :new, project_id: 1) }
    it { is_expected.to route(:post, '/projects/1/bugs').to(action: :create, project_id: 1) }
    it { is_expected.to route(:get, '/projects/1/bugs/1/edit').to(action: :edit, project_id: 1, id: 1) }
    it { is_expected.to route(:put, '/projects/1/bugs/1').to(action: :update, project_id: 1, id: 1) }
    it { is_expected.to route(:patch, '/projects/1/bugs/1').to(action: :update, project_id: 1, id: 1) }
    it { is_expected.to route(:delete, '/projects/1/bugs/1').to(action: :destroy, project_id: 1, id: 1) }
    it { is_expected.to route(:post, '/projects/1/bugs/1/assign').to(action: :assign, project_id: 1, id: 1) }
    it { is_expected.to route(:post, '/projects/1/bugs/1/update_status').to(action: :update_status, project_id: 1, id: 1) }
  end

  describe 'GET #index' do
    RSpec.shared_examples 'index successfull' do
      it 'returns a successful response' do
        expect(response).to be_successful
      end

      it 'renders the index template' do
        expect(response).to render_template(:index)
      end

      it 'assigns @bugs' do
        expect(assigns(:bugs)).to include(bug)
      end
    end

    context 'when qa requests index' do
      before { get :index, params: { project_id: project.id } }

      include_examples 'index successfull'
    end

    context 'when manager requests index' do
      before do
        sign_in project.manager
        get :index, params: { project_id: project.id }
      end

      include_examples 'index successfull'
    end

    context 'when developer requests index' do
      before do
        sign_in developer
        get :index, params: { project_id: project.id }
      end

      include_examples 'index successfull'
    end

    context 'when requesting invalid project bugs' do
      before { get :index, params: { project_id: 0 } }

      include_examples 'record not found'
    end

    context 'when user is unauthorized' do
      login_developer

      before { get :index, params: { project_id: project.id } }

      include_examples 'unauthorized user'
    end
  end

  describe 'GET #show' do
    RSpec.shared_examples 'show successfull' do
      it 'have http status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'return the bug' do
        expect(assigns(:bug)).to eq(bug)
      end

      it 'respond with show' do
        expect(response).to render_template(:show)
      end
    end

    context 'when qa requests bug show' do
      before do
        get :show, params: { project_id: bug.project.id, id: bug.id }
      end

      include_examples 'show successfull'
    end

    context 'when manager requests bug show' do
      before do
        sign_in bug.project.manager
        get :show, params: { project_id: bug.project.id, id: bug.id }
      end

      include_examples 'show successfull'
    end

    context 'when project developer requests bug show' do
      before do
        sign_in developer
        get :show, params: { project_id: bug.project.id, id: bug.id }
      end

      include_examples 'show successfull'
    end

    context 'when requesting invalid bug' do
      before { get :show, params: { project_id: bug.project.id, id: 0 } }

      include_examples 'record not found'
    end

    context 'when user is unauthorized' do
      login_developer

      before do
        get :show, params: { project_id: bug.project.id, id: bug.id }
      end

      include_examples 'unauthorized user'
    end
  end

  describe 'GET #new' do
    context 'with new project' do
      before do
        get :new, params: { project_id: bug.project.id }
      end

      it 'have http status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'respond with new' do
        expect(response).to render_template(:new)
      end

      it 'assign a @bug' do
        expect(assigns(:bug)).not_to be_nil
      end
    end

    context 'when requesting to create invalid project bug' do
      before do
        get :new, params: { project_id: 0 }
      end

      include_examples 'record not found'
    end

    context 'when user is unauthorized' do
      login_developer

      before do
        get :new, params: { project_id: bug.project.id }
      end

      include_examples 'unauthorized user'
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      before do
        post :create, params: {
          project_id: project.id,
          bug: attributes_for(:bug)
        }
      end

      it 'assign a value to @bug' do
        expect(assigns(:bug)).not_to be_nil
      end

      it 'create a bug and redirect to the bugs' do
        expect(response).to redirect_to project_bugs_url(bug.project)
      end

      it { is_expected.to set_flash[:notice].to(I18n.t('bug_reported')) }
    end

    context 'with invalid attributes' do
      before do
        post :create, params: { project_id: project.id, bug: { title: nil }, id: bug.id }
      end

      it 'does not create bug and render' do
        expect(response).to render_template(:new)
      end
    end

    context 'when requesting to create invalid project bug' do
      before do
        post :create, params: {
          project_id: 0,
          bug: attributes_for(:bug)
        }
      end

      include_examples 'record not found'
    end
  end

  describe 'GET #edit' do
    context 'when editing existing bug' do
      before do
        get :edit, params: {
          project_id: bug.project.id,
          id: bug.id
        }
      end

      it 'http status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'assign a value to @bug' do
        expect(assigns(:bug)).not_to be_nil
      end

      it 'respond with edit' do
        expect(response).to render_template(:edit)
      end
    end

    context 'when requesting to edit invalid project bug' do
      before do
        get :edit, params: {
          project_id: bug.project.id,
          id: 0
        }
      end

      include_examples 'record not found'
    end

    context 'when user is unauthorized' do
      login_developer

      before do
        get :edit, params: {
          project_id: bug.project.id,
          id: bug.id
        }
      end

      include_examples 'unauthorized user'
    end
  end

  describe 'POST #update' do
    context 'when updating bug' do
      before do
        patch :update, params: {
          bug: {
            title: 'Updated bug',
            description: 'lorem ispum updated'
          },
          project_id: bug.project.id,
          id: bug.id
        }
      end

      it 'assign a value to @bug' do
        expect(assigns(:bug)).not_to be_nil
      end

      it 'check if updated title' do
        expect(bug).to be_saved_change_to_title
      end

      it 'update project and redirect to bugs' do
        expect(response).to redirect_to project_bugs_url(bug.project)
      end

      it { is_expected.to set_flash[:notice].to(I18n.t('bug_updated')) }
    end

    context 'when updating bug with invalid attributes' do
      before { patch :update, params: { bug: { title: nil }, project_id: bug.project.id, id: bug.id } }

      it 'does not update bug and render' do
        expect(response).to render_template(:edit)
      end

      it { is_expected.to set_flash[:alert].to(I18n.t('bug_not_updated')) }
    end

    context 'when requesting to edit invalid project bug' do
      before do
        patch :update, params: {
          bug: {
            title: 'Updated bug',
            description: 'lorem ispum updated'
          },
          project_id: bug.project.id,
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
          delete :destroy, params: { project_id: bug.project.id, id: bug.id }
        end.to change(Bug, :count).by(-1)
      end
    end

    context 'when deleting valid bug' do
      before { delete :destroy, params: { project_id: bug.project.id, id: bug.id } }

      it 'delete a bug when user is logged in and redirect' do
        expect(response).to redirect_to project_bugs_url(bug.project)
      end

      it 'assign a value to @bug' do
        expect(assigns(:bug)).not_to be_nil
      end

      it { is_expected.to set_flash[:notice].to(I18n.t('bug_deleted')) }
    end

    context 'when deleting invalid bug' do
      before do
        allow_any_instance_of(Bug).to receive(:destroy).and_return(false)
        delete :destroy, params: { id: bug.id, project_id: bug.project.id }
      end

      it 'does not change count' do
        expect do
          delete :destroy, params: { id: bug.id, project_id: bug.project.id }
        end.not_to change(Bug, :count)
      end

      it 'renders template' do
        expect(response).to render_template(:index)
      end

      it { is_expected.to set_flash[:alert].to(I18n.t('bug_not_deleted')) }
    end

    context 'when requesting to delete invalid project bug' do
      before { delete :destroy, params: { project_id: bug.project.id, id: 0 } }

      include_examples 'record not found'
    end

    context 'when user is unauthorized' do
      login_developer

      before { delete :destroy, params: { project_id: bug.project.id, id: bug.id } }

      include_examples 'unauthorized user'
    end
  end

  describe 'POST #assign' do
    context 'when assigning bug to valid user' do
      before do
        sign_in developer
        post :assign, params: { project_id: bug.project.id, id: bug.id }
      end

      it 'assign a value to @bug' do
        expect(assigns(:bug)).not_to be_nil
      end

      it 'assign bug to developer' do
        bug.developer = developer
        expect(developer).to be(bug.developer)
      end

      it 'assign bug and redirect to bug' do
        expect(response).to redirect_to project_bug_url(bug.project)
      end

      it { is_expected.to set_flash[:notice].to(I18n.t('bug_assigned')) }
    end

    context 'when user is unauthorized' do
      before do
        sign_in qa
        post :assign, params: { project_id: bug.project.id, id: bug.id }
      end

      include_examples 'unauthorized user'
    end
  end

  describe 'POST #update_status' do
    context 'when updating bug status' do
      before do
        sign_in developer
        post :update_status, params: {
          project_id: bug.project.id,
          id: bug.id,
          status: 'completed'
        }
      end

      it 'assign a value to @bug' do
        expect(assigns(:bug)).not_to be_nil
      end

      it 'successful update' do
        expect(assigns(:bug).status).to eq('completed')
      end

      it 'update bug and redirect to bug' do
        expect(response).to redirect_to project_bug_path(bug.project, bug)
      end
    end

    context 'when updating bug status with invalid status' do
      before do
        sign_in developer
        post :update_status, params: {
          project_id: bug.project.id,
          id: bug.id,
          status: 'completedfd'
        }
      end

      it 'update bug and redirect to bug' do
        expect(response).to render_template(:show)
      end

      it { is_expected.to set_flash[:alert].to(I18n.t('bug_status_not_updated')) }
    end

    context 'when user is unauthorized' do
      before do
        sign_in qa
        post :update_status, params: {
          project_id: bug.project.id,
          id: bug.id,
          status: 'completed'
        }
      end

      include_examples 'unauthorized user'
    end
  end
end
