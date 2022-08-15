# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show]
  before_action :set_owned_blog, only: %i[edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    validated_params = validate_premium_features(blog_params)
    @blog = current_user.blogs.new(validated_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    validated_params = validate_premium_features(blog_params)
    if @blog.update(validated_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    return @blog = Blog.find_by!(id: params[:id], secret: false) unless user_signed_in?

    blog = Blog.find(params[:id])
    return @blog = blog unless blog.secret

    set_owned_blog
  end

  def set_owned_blog
    @blog = current_user.blogs.find(params[:id])
  end

  def blog_params
    params.require(:blog).permit(:title, :content, :secret, :random_eyecatch)
  end

  def validate_premium_features(params)
    params[:random_eyecatch] = false unless current_user.premium
    params
  end
end
