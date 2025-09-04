package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestBasicExample(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",
		Vars: map[string]interface{}{
			"environment": "test",
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndPlan(t, terraformOptions)

	output := terraform.Plan(t, terraformOptions)
	assert.NotEmpty(t, output)
}

func TestSQSModule(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",
		Vars: map[string]interface{}{
			"environment": "test",
		},
		Target: []string{"module.event_queue"},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndPlan(t, terraformOptions)

	output := terraform.Plan(t, terraformOptions)
	assert.NotEmpty(t, output)
}

func TestLambdaModule(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",
		Vars: map[string]interface{}{
			"environment": "test",
		},
		Target: []string{"module.event_processor"},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndPlan(t, terraformOptions)

	output := terraform.Plan(t, terraformOptions)
	assert.NotEmpty(t, output)
}
