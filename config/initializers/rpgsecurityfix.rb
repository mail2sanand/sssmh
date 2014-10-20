ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML) if Rails::VERSION::STRING.to_i == 3
