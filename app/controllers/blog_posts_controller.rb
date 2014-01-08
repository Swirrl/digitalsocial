class BlogPostsController < ApplicationController

  def show
    @blog_post = BlogPost.published.find(params[:id])
    @title = "#{@blog_post.name} | Blog"
  end

  def index
    @blog_posts = BlogPost.published.order_by(publish_at: :desc)
  end

  def tag
    @tag = params[:tag]
    @title = @tag.humanize
    @blog_posts = BlogPost.published.order_by(publish_at: :desc).where(tags: @tag)
  end

end