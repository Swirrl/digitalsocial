class Admin::AttachmentsController < AdminController

  def index
    @attachments = Attachment.all
  end

  def new
    @attachment = Attachment.new
  end

  def create
    @attachment = Attachment.new(params[:attachment])

    if @attachment.save
      redirect_to [:admin, :attachments], notice: "Attachment was created!"
    else
      render :new
    end
  end

  def edit
    @attachment = Attachment.find(params[:id])
  end

  def update
    @attachment = Attachment.find(params[:id])

    if @attachment.update_attributes(params[:attachment])
      redirect_to [:admin, :attachments], notice: "Attachment was updated!"
    else
      render :edit
    end
  end

  def destroy
    @attachment = Attachment.find(params[:id])

    if @attachment.destroy
      redirect_to [:admin, :attachments], notice: "Attachment was deleted!"
    end
  end

end