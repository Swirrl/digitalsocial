class Admin::BlogPostsController < AdminController

  def index
    @blog_posts = BlogPost.asc(:start_date).all
  end

  def new
    @blog_post = BlogPost.new
  end

  def create
    @blog_post = BlogPost.new(params[:blog_post])

    if @blog_post.save
      redirect_to [:admin, :blog_posts], notice: "Blog post was created!"
    else
      render :new
    end
  end

  def edit
    @blog_post = BlogPost.find(params[:id])
  end

  def update
    @blog_post = BlogPost.find(params[:id])

    if @blog_post.update_attributes(params[:blog_post])
      redirect_to [:admin, :blog_posts], notice: "Blog post was updated!"
    else
      render :edit
    end
  end

  def destroy
    @blog_post = BlogPost.find(params[:id])

    if @blog_post.destroy
      redirect_to [:admin, :blog_posts], notice: "Blog post was deleted!"
    end
  end

end