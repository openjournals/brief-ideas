require 'html/pipeline'

class Comment < ActiveRecord::Base
  include ActsAsCommentable::Comment

  belongs_to :commentable, :polymorphic => true

  default_scope -> { order('created_at ASC') }

  validates_length_of :comment,
                      :within => 1..100,
                      :allow_blank => false,
                      :too_long => "Please limit your comment to 100 words",
                      :tokenizer => lambda { |str| str.scan(/\w+/) }
  after_create :notify
  belongs_to :user

  def notify
    Notification.comment_email(self).deliver
  end

  def formatted_comment
    pipeline = HTML::Pipeline.new [
      HTML::Pipeline::MarkdownFilter,
      HTML::Pipeline::SanitizationFilter
    ]
    result = pipeline.call(comment)
    result[:output].to_s
  end
end
