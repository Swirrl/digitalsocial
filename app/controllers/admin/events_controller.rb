class Admin::EventsController < AdminController

  def index
    @events = Event.asc(:start_date).all
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(params[:event])

    if @event.save
      redirect_to [:admin, :events], notice: "Event was created!"
    else
      render :new
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])

    if @event.update_attributes(params[:event])
      redirect_to [:admin, :events], notice: "Event was updated!"
    else
      render :edit
    end
  end

  def destroy
    @event = Event.find(params[:id])

    if @event.destroy
      redirect_to [:admin, :events], notice: "Event was deleted!"
    end
  end

end