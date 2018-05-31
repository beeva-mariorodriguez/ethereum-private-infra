resource "aws_api_gateway_rest_api" "ethereum" {
  name        = "ethereum"
  description = "ethereum"
}

# /enode
resource "aws_api_gateway_resource" "enode" {
  rest_api_id = "${aws_api_gateway_rest_api.ethereum.id}"
  parent_id   = "${aws_api_gateway_rest_api.ethereum.root_resource_id}"
  path_part   = "/enode"
}

resource "aws_api_gateway_method" "enode" {
  rest_api_id   = "${aws_api_gateway_rest_api.ethereum.id}"
  resource_id   = "${aws_api_gateway_resource.enode.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "enode" {
  rest_api_id = "${aws_api_gateway_rest_api.ethereum.id}"
  resource_id = "${aws_api_gateway_method.enode.resource_id}"
  http_method = "${aws_api_gateway_method.enode.http_method}"

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "${aws_instance.ethereum_proxy.public_ip}:8080"
}

# /json
resource "aws_api_gateway_resource" "json" {
  rest_api_id = "${aws_api_gateway_rest_api.ethereum.id}"
  parent_id   = "${aws_api_gateway_rest_api.ethereum.root_resource_id}"
  path_part   = "/json"
}

resource "aws_api_gateway_method" "json" {
  rest_api_id   = "${aws_api_gateway_rest_api.ethereum.id}"
  resource_id   = "${aws_api_gateway_resource.json.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "json" {
  rest_api_id = "${aws_api_gateway_rest_api.ethereum.id}"
  resource_id = "${aws_api_gateway_method.enode.resource_id}"
  http_method = "${aws_api_gateway_method.enode.http_method}"

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "${aws_instance.bastion.public_ip}:8080/InnovationDay.json"
}

# deployment

resource "aws_api_gateway_deployment" "ethereum" {
  depends_on = [
    "aws_api_gateway_integration.enode",
    "aws_api_gateway_integration.json",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.ethereum.id}"
  stage_name  = "dev"
}
