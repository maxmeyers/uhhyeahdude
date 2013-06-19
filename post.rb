require 'aws/s3'
include AWS::S3

AWS::S3::Base.establish_connection!(
  :access_key_id     => 'AKIAJIIBLPNSSKSEWS5A',
  :secret_access_key => '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'
)

S3Object.store('update', Time.now.to_i.to_s, 'uhhyeahdude', :access => :public_read)