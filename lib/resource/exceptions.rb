class Resource
  class Unimplemented < ::StandardError; end
  class MissingProperties < ::StandardError; end
  class ResourceAlreadyExists < ::StandardError; end
  class ResourceDoesNotExist < ::StandardError; end
  class ResourceNotFound < ::StandardError; end
  class ResourceTookToLong < ::StandardError; end
end
