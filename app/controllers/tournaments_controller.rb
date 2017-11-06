class TournamentsController < ApplicationController
  before_action :set_tournament, only: [:show, :edit, :update, :destroy, :join_tournament, :leave_tournament, :has_team?]
  before_action :has_team?, only: [:join_tournament]

  def has_team?
    if current_user.team.nil?
      flash[:error] = "You need to create/join team to join tournaments."
      redirect_to tournaments_url
    end
  end

  # GET /tournaments
  # GET /tournaments.json
  def index
    @tournaments = Tournament.all
  end

  # GET /tournaments/1
  # GET /tournaments/1.json
  def show
    if current_user.team.present? && @tournament.participants.exists?(team_id: current_user.team.id)
      @current_user_in_tournament = true
    else
      @current_user_in_tournament = false
    end
  end

  # GET /tournaments/new
  def new
    @tournament = Tournament.new
  end

  # GET /tournaments/1/edit
  def edit
  end

  # POST /tournaments
  # POST /tournaments.json
  def create
    @tournament = Tournament.new(tournament_params)
    @tournament.user_id = current_user.id
    respond_to do |format|
      if @tournament.save
        flash[:success] = 'Tournament was successfully created.'
        format.html { redirect_to @tournament}
        format.json { render :show, status: :created, location: @tournament }
      else
        format.html { render :new }
        format.json { render json: @tournament.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tournaments/1
  # PATCH/PUT /tournaments/1.json
  def update
    respond_to do |format|
      if @tournament.update(tournament_params)
        flash[:success] = 'Tournament was successfully updated.'
        format.html { redirect_to @tournament}
        format.json { render :show, status: :ok, location: @tournament }
      else
        format.html { render :edit }
        format.json { render json: @tournament.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tournaments/1
  # DELETE /tournaments/1.json
  def destroy
    @tournament.destroy
    respond_to do |format|
      flash[:success] = 'Tournament was successfully destroyed.'
      format.html { redirect_to tournaments_url}
      format.json { head :no_content }
    end
  end

  def join_tournament
    if @tournament.user != current_user
      if @tournament.user.team != current_user.team
        participant = Participant.create(tournament_id: @tournament.id,team_id: current_user.team.id)
        respond_to do |format|
          if participant.save
            flash[:success] = "Your team successfully join the tournament."
            format.html { redirect_to @tournament}
            format.json { render :show, status: :created, location: @tournament }
          else
            format.html { render :new }
            format.json { render json: @tournament.errors, status: :unprocessable_entity }
          end
        end 
      else
        flash[:error] = "You cannot join tournament created by your teammate."
        redirect_to tournaments_url
     end 
    else
      flash[:error] = 'You cannot join your own tournaments.'
      redirect_to tournaments_url
    end
  end

  def leave_tournament
    Participant.where(tournament_id: @tournament.id,team_id: current_user.team.id).first.destroy
    respond_to do |format|
      flash[:success] = 'You successully left the tournament.'
      format.html { redirect_to tournaments_url}
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tournament
      @tournament = Tournament.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tournament_params
      params.require(:tournament).permit(:user_id, :name, :tournament_type_id, :start_date, :finished)
    end
end
