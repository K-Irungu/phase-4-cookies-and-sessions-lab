class ArticlesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found


  def index
    articles = Article.all.includes(:user).order(created_at: :desc)
    render json: articles, each_serializer: ArticleListSerializer
  end

  def show
    # Sets page_views counter to an initial value of 0
    session[:page_views] ||= 0

    # Increment the number of page views every time sessions#show is called
    session[:page_views] = session[:page_views].to_i + 1

    # Checks if page_view limit has been reached
    if session[:page_views] <= 3
      article = Article.find(params[:id])
      render json: article, status: :ok
    else
      # Throws an error when page limit is reached
      render json: { error: "Maximum pageview limit reached" }, status: :unauthorized
    end

  end

  private

  def record_not_found
    render json: { error: "Article not found" }, status: :not_found
  end

end
