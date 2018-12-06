# see if the request is for activestorage
# if it is, return false
# else return true
class ActiveStorageRouteConstraint
  def self.matches?(request)
    !(request.env["REQUEST_PATH"] =~ /active_storage/)
  end
end