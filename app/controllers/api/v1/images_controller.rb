require 'aws-sdk-s3'

class Api::V1::ImagesController < ApplicationController
    # GET /api/v1/images?:name&:format
    def index
        begin
            # Extract the file name and extension from the URL
            name = params[:name]
            format = params[:format]
        
            s3 = s3_resource
            bucket = s3.bucket(ENV['AWS_BUCKET_NAME'])
            object = bucket.object("#{name}.#{format}")
            
            image_data = object.get.body.read
  
            send_data image_data, type: "image/#{format}", disposition: 'inline'
        rescue => e
            render json: { error: e.message }, status: :unprocessable_entity
        end
    end

    # POST /api/v1/images
    def create
        begin
            s3 = s3_resource
            bucket = s3.bucket(ENV['AWS_BUCKET_NAME'])
            image = params[:image]
            object = bucket.object(image.original_filename)
            object.upload_file(image.tempfile, acl: 'private')
            
            render json: {name: image.original_filename.split('.')[0], format: image.original_filename.split('.')[1]}, status: :created
        rescue => e
            render json: { error: e.message }, status: :unprocessable_entity
        end
    end

    # POST /api/v1/images/create_multiple
    def create_multiple
        name_format = []
        begin
            s3 = s3_resource
            bucket = s3.bucket(ENV['AWS_BUCKET_NAME'])
            params[:images].each do |image|
                object = bucket.object(image.original_filename)
                object.upload_file(image.tempfile, acl: 'private')
                name_format << {name: image.original_filename.split('.')[0], format: image.original_filename.split('.')[1]}
            end
            render json: { images: name_format }, status: :created
        rescue => e
            render json: { error: e.message }, status: :unprocessable_entity
        end
    end

    private

    def s3_resource
        Aws::S3::Resource.new(
          access_key_id: ENV['AWS_ACCESS_KEY_ID'],
          secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
          region: ENV['AWS_REGION']
        )
    end
end
