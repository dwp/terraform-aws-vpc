package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"

	"path/filepath"

	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

// Terratest functions for testing the VPC module
func TestVPC(t *testing.T) {
	t.Parallel()

	// AWS Region set as eu-west-1 as standard.
	awsRegion := "eu-west-1"

	// set up variables for other module variables so assertions may be made on them later

	// Terraform plan.out File Path
	exampleFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "example/")
	planFilePath := filepath.Join(exampleFolder, "plan.out")


	terraformOptionsVPC := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../example",
		Upgrade:      true,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{

		},

		//Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},

		// Configure a plan file path so we can introspect the plan and make assertions about it.
		PlanFilePath: planFilePath,
	})

	// website::tag::2::Run `terraform init`, `terraform plan`, and `terraform show` and fail the test if there are any errors
	plan := terraform.InitAndPlanAndShowWithStruct(t, terraformOptionsVPC)


	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptionsVPC)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptionsVPC)

	// website::tag::3::Use the go struct to introspect the plan values.
	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.vpc.aws_vpc.vpc")


	// Run `terraform output` to get the value of an output variable
	// Retrieve all the outputs from the module
	vpcID := terraform.Output(t, terraformOptionsVPC, "id")


	// To get the value of an output variable, run 'terraform output'
	Tags := terraform.OutputMap(t, terraformOptionsVPC, "tags")


	// Assert that all output Variables are populated
	lengthOfVpcID := len(vpcID)

	// Check that we get back the outputs that we expect
	assert.Equal(t, "vpc-module-test", Tags["Name"])

	// Verify the Vpc parameters
	assert.NotEqual(t, lengthOfVpcID, 0, "VPC ID Output MUST be populated")


}
