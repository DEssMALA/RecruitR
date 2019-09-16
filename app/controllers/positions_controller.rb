class PositionsController < ApplicationController
  def index
    @positions = Position.all
  end

  def show
    @position = Position.find(params[:id])
    get_position_skills
    get_position_traits
  end

  def new
    @position = Position.new
  end

  def edit
    @position = Position.find(params[:id])
    get_position_skills
    get_position_traits
  end

  def create

    # Newly created positions are active by default.
    params[:position]["active"] = true

    # Saving new position
    @position = Position.new(position_params)
    if @position.save

      # Get array of skills and traits
      skills = listify_from_string(params[:skills])
      traits = listify_from_string(params[:traits])

      # Put skills in db and associate to position
      add_associations(Skill, skills, @position)

      # Put traits in db and associate to position
      add_associations(Trait, traits, @position)

      redirect_to @position
    else
      render 'new'
    end

  end

  def update
    @position = Position.find(params[:id])

    current_skills = get_position_skills
    current_traits = get_position_traits
    
    new_skills = listify_from_string(params[:skills])
    new_traits = listify_from_string(params[:traits])

    if @position.update(position_params)
      if current_skills != new_skills
        # Remove all skills from this position
        @position.skills.clear
        # Put skills in db and associate to position
        add_associations(Skill, new_skills, @position)
      end

      if current_traits != new_traits
        # Remove all traits from this position
        @position.traits.clear
        # Put traits in db and associate to position
        add_associations(Trait, new_traits, @position)
      end
      redirect_to @position
    else
      render 'edit'
    end
  
  end

  def destroy
    @position = Position.find(params[:id])
    @position.destroy

    redirect_to positions_path
  end

  
  private
    # Check that parameters contains only allowed values.
    def position_params
      params.require(:position).permit(:title, :description, :active)
    end

    def get_position_skills
      @skills = []
      for s in @position.skills do
        @skills.push(s.name)
      end
      return @skills
    end

    def get_position_traits
      @traits = []
      for t in @position.traits do
        @traits.push(t.name)
      end
      return @traits
    end
end
