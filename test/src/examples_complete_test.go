package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	t.Parallel()

	// rand.Seed(time.Now().UnixNano())
	// randID := strconv.Itoa(rand.Intn(100000))

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/complete",
		Upgrade:      false,
	}

	// Run `terraform destroy` after test to clean up any resources that were created
	// defer terraform.Destroy(t, terraformOptions)

	// Run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndPlan(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
}
