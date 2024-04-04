# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :set_projects, only: %i[show edit update destroy]

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @projects = policy_scope(Project).page(params[:page])
  end

  def show
    authorize @project
  end

  def new
    @project = current_user.projects.build
    authorize @project
  end

  def edit
    authorize @project
  end

  def create
    @project = current_user.projects.build(project_params)
    authorize @project
    if @project.save
      @project.assign_user(params[:project][:users])
      flash[:notice] = I18n.t 'project_added'
      redirect_to projects_path
    else
      render :new
    end
  end

  def update
    authorize @project
    if @project.update(project_params)
      @project.assign_user(params[:project][:users])
      flash[:notice] = I18n.t 'project_updated'
      redirect_to projects_path
    else
      flash[:alert] = I18n.t 'project_not_updated'
      render :edit
    end
  end

  def destroy
    authorize @project
    if @project.destroy
      flash[:notice] = I18n.t 'project_deleted'
      respond_to do |format|
        format.html { redirect_to projects_path }
        format.js
      end
    else
      flash[:alert] = I18n.t 'project_not_deleted'
      render :index
    end
  end

  def remove_user
    @project = Project.find(params[:project_id])
    @assignment = Assignment.find(params[:id])
    authorize @project
    if @assignment.destroy
      helpers.unassign_bug(@assignment, @project)
      respond_to do |format|
        format.html { redirect_to project_path(@project) }
        format.js
      end
    else
      render :show
    end
  end

  private

  def set_projects
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:title, :description)
  end
end
