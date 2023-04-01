class ExpiredError < StandardError
    def initialize(msg = "Token has expired")
        super
    end
end