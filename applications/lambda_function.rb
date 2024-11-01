require 'aws-sdk-dynamodb'

TABLE_NAME = 'Users-staging'

def lambda_handler(event:, context:)
  # DynamoDB からユーザーのメールアドレスを取得する
  begin
    dynamodb = Aws::DynamoDB::Client.new(region: 'ap-northeast-1')
    response = dynamodb.scan({
      table_name: TABLE_NAME,
      select: 'SPECIFIC_ATTRIBUTES',
      attributes_to_get: ['Email']
    })
    response.items.map { |item| item['Email'] }
  rescue Aws::DynamoDB::Errors::ServiceError => e
    # TODO: ClowdWatch にログを出力するように変更する
    puts "Unable to fetch emails: #{e.message}"
    raise "Unable to fetch emails: #{e.message}"
  end
end
