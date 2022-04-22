terraform {
  required_providers {
    datadog = {
      source = "datadog/datadog"
      version = "~> 2.18.1"
    }
  }
  required_version = ">=0.13.5"
}