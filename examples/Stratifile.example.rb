target 'production' do
  role_arn ARN
end

file 'lambda/app.zip' do
  source 'build/app.zip'
end

stack 'stratiform-test' do
  targets ['production']
  iam_capability true
end
