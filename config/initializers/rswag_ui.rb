Rswag::Ui.configure do |c|
  c.swagger_endpoint "/api-docs/v1/swagger.yaml", "花语心途 API V1"
  c.config_object[:deepLinking] = true
  c.config_object[:displayRequestDuration] = true
  c.config_object[:persistAuthorization] = true
end
