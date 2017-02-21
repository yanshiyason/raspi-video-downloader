require_relative './notification_processor'

class SnsProcessor

  attr_reader :sns_client

  def initialize(request)
    puts 'initializing processor'
    @request = request
    @sns_client = Aws::SNS::Client.new(region: 'us-east-1')
  end

  def process!
    perform_process
  end

  private

  def notification
    @notification ||= JSON.parse(body)
  end

  def body
    @body ||= @request.body.read
  end

  def perform_process
    case notification['Type']
    when 'SubscriptionConfirmation'
      confirm_subscription
    when 'UnsubscribeConfirmation'
      '200'
    when 'Notification'
      NotificationProcessor.new(notification).process!
    end
  end

  def confirm_subscription
    sns_client.confirm_subscription(
      topic_arn:      notification['TopicArn'],
      token:          notification['Token'],
      authenticate_on_unsubscribe: 'true'
    )
  end
end
