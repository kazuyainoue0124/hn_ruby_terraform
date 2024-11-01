require 'aws-sdk-dynamodb'
require 'aws-sdk-ses'

TABLE_NAME = 'Users-staging'
SUBJECT = 'Daily Ruby News Digest'

def lambda_handler(event:, context:)
  # DynamoDB からユーザーのメールアドレスを取得する
  dynamodb = Aws::DynamoDB::Client.new(region: 'ap-northeast-1')
  begin
    response = dynamodb.scan({
      table_name: TABLE_NAME,
      select: 'SPECIFIC_ATTRIBUTES',
      attributes_to_get: ['Email']
    })
  rescue Aws::DynamoDB::Errors::ServiceError => e
    # TODO: ClowdWatch にログを出力するように変更する
    puts "Unable to fetch emails: #{e.message}"
    raise "Unable to fetch emails: #{e.message}"
  end

  # DynamoDB から取得したメールアドレスへ SES で送信する
  emails = response.items.map { |item| item['Email'] }
  ses = Aws::SES::Client.new(region: 'ap-northeast-1')
  begin
    emails.each do |email|
      ses.send_email({
        destination: {
          to_addresses: [email]
        },
        message: {
          body: {
            html: {
              charset: 'UTF-8',
              data: 'テストです'
            },
            text: {
              charset: 'UTF-8',
              data: 'テストです'
            }
          },
          subject: {
            charset: 'UTF-8',
            data: SUBJECT
          }
        },
        # テスト環境では sender@example.com を使用する
        source: ENV['SES_SOURCE_EMAIL'] || 'sender@example.com'
      })
    end
  rescue Aws::SES::Errors::ServiceError => e
    # TODO: ClowdWatch にログを出力するように変更する
    puts "Unable to send email: #{e.message}"
    raise "Unable to send email: #{e.message}"
  end
end
