require_relative 'expired_error'
require 'base64'
require 'httparty'
require 'jwt'

class FirebaseToken
  JWT_ALGORITHM = 'RS256'.freeze
  PUBLIC_KEY_URL = 'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com'.freeze

  def initialize(token)
    @token = token
  end

  def verify()
    header = decode_header
    alg = header['alg']
    kid = header['kid']

    if alg != JWT_ALGORITHM
      raise "Invalid token 'alg' header (#{alg}). Must be '#{JWT_ALGORITHM}'."
    end

    public_key = get_public_key(kid)

    verify_jwt(public_key)
  end

  private

  def decode_header
    encoded_header = @token.split('.').first
    JSON.parse(Base64.decode64(encoded_header))
  end

  def get_public_key(kid)
    response = HTTParty.get(PUBLIC_KEY_URL)

    unless response.success?
      raise "Failed to fetch JWT public keys from Google."
    end

    public_keys = response.parsed_response

    # TODO: cache public_keys to avoid downloading it every time.
    # Use the cache-control header for TTL.

    unless public_keys.include?(kid)
      raise "Invalid token 'kid' header, do not correspond to valid public keys."
    end

    OpenSSL::X509::Certificate.new(public_keys[kid]).public_key
  end

  def verify_jwt(public_key)
    options = {
      algorithm: JWT_ALGORITHM,
      verify_iat: true,
      verify_aud: true,
      aud: ENV['PROJECT_ID'],
      verify_iss: true,
      iss: "https://securetoken.google.com/#{ENV['PROJECT_ID']}"
    }

    begin
      JWT.decode(@token, public_key, true, options)
    rescue JWT::ExpiredSignature
      raise ExpiredError.new
    end
  end
end