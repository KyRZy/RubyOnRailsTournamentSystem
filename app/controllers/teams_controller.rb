require 'bcrypt'

class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :edit, :update, :destroy]

  # GET /teams
  # GET /teams.json
  def index
    @teams = Team.all
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
  end

  # GET /teams/new
  def new
    @team = Team.new
  end

  # GET /teams/1/edit
  def edit
  end

  # POST /teams
  # POST /teams.json
  def create
    if params[:password] == params[:password_confirmation]
      @team = Team.new(team_params)
      @team.leader_id = current_user.id
      @team.salt = BCrypt::Engine.generate_salt
      @team.encrypted_password= BCrypt::Engine.hash_secret(params[:password], @team.salt)
      Team.transaction do
        if @team.save
          current_user.team_id = @team.id
          respond_to do |format|
            if current_user.save
              flash[:success] = 'Team was successfully created.'
              format.html { redirect_to root_url}
              format.json { render :show, status: :created, location: @team }
            else
              format.html { render :new }
              format.json { render json: @team.errors, status: :unprocessable_entity }
            end
          end
        else
          flash[:error] = 'This team name is already taken.'
          redirect_to new_team_path
        end
      end
    else
      flash[:error] = 'Password and password confirmation don\'t match.'
      redirect_to new_team_path
    end
  end

  # PATCH/PUT /teams/1
  # PATCH/PUT /teams/1.json
  def update
    respond_to do |format|
      if @team.update(team_params)
        flash[:success] = 'Team was successfully updated.'
        format.html { redirect_to @team}
        format.json { render :show, status: :ok, location: @team }
      else
        format.html { render :edit }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1
  # DELETE /teams/1.json
  def destroy
    Team.transaction do
      successfull_save = true

      @team.users.each do |user|
        user.team = nil
        successfull_save = successfull_save and user.save
      end
      if successfull_save
        @team.destroy
        respond_to do |format|
          flash[:success] = 'Team was successfully destroyed.'
          format.html { redirect_to teams_url}
          format.json { head :no_content }
        end
      end
    end
  end

  def join_existing_team
    name = params[:name]
    password = params[:password]

    if team = Team.where(name: name).first
      if team.encrypted_password == BCrypt::Engine.hash_secret(password, team.salt)
        current_user.team_id = team.id
        respond_to do |format|
          if current_user.save
            flash[:success] = 'You successfully joined the team.'
            format.html { redirect_to team}
            format.json { render :show, status: :created, location: team }
          else
            format.html { render :new }
            format.json { render json: current_user.errors, status: :unprocessable_entity }
          end
        end
      else
        flash[:error] = 'Wrong password.'
        redirect_to new_team_path
      end
    else
      flash[:error] = 'Team does not exist.'
      redirect_to new_team_path
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_team
      @team = Team.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def team_params
      params.require(:team).permit(:name, :password)
    end
end
