class BlogPostsController < ApplicationController

  def show
    @blog_post = BlogPost.published.find(params[:id])
  end

  def index
    @blog_posts = BlogPost.published.order_by(publish_at: :desc)
  end

end