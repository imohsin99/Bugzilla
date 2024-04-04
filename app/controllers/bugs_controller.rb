# frozen_string_literal: true

class BugsController < ApplicationController
  before_action :set_project, only: %i[index new create]
  before_action :set_bug, except: %i[index new create]

  after_action :verify_authorized, except: :index

  def index
    @bugs = BugPolicy::Scope.new(current_user, @project).resolve.page(params[:page]).per(8)
  end

  def show
    authorize @bug
  end

  def new
    @bug = @project.bugs.build
    authorize @bug
  end

  def edit
    authorize @bug
  end

  def create
    @bug = @project.bugs.build(bug_params)
    @bug.creator_id = current_user.id
    authorize @bug
    if @bug.save
      flash[:notice] = I18n.t 'bug_reported'
      redirect_to project_bugs_path(@project)
    else
      render :new
    end
  end

  def update
    authorize @bug
    if @bug.update(bug_params)
      flash[:notice] = I18n.t 'bug_updated'
      redirect_to project_bugs_path(@project)
    else
      flash[:alert] = I18n.t 'bug_not_updated'
      render :edit
    end
  end

  def destroy
    authorize @bug
    if @bug.destroy
      flash[:notice] = I18n.t 'bug_deleted'
      respond_to do |format|
        format.html { redirect_to project_bugs_path(@project) }
        format.js
      end
    else
      flash[:alert] = I18n.t 'bug_not_deleted'
      render :index
    end
  end

  def assign
    @bug.developer = current_user
    authorize @bug
    @bug.save
    flash[:notice] = I18n.t 'bug_assigned'
    respond_to do |format|
      format.html { redirect_to project_bug_path(@project, @bug) }
      format.js
    end
  end

  def update_status
    authorize @bug
    if @bug.check_status_param?(params[:status])
      @bug.update(status: params[:status])
      respond_to do |format|
        format.html { redirect_to project_bug_path(@project, @bug) }
        format.js
      end
    else
      flash[:alert] = I18n.t 'bug_status_not_updated'
      render :show
    end
  end

  private

  def set_bug
    set_project
    @bug = @project.bugs.find(params[:id])
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

  def bug_params
    params.require(:bug).permit(:title, :description, :deadline, :bug_type, :screenshot)
  end
end
