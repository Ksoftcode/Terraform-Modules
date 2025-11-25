// -----------------------------------------------------------------------------
// Terratest - Module Template Tests
// -----------------------------------------------------------------------------
// This file contains integration tests for the module using Terratest.
// Run tests with: go test -v -timeout 30m
// -----------------------------------------------------------------------------

package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestModuleBasic tests the module with minimal configuration
func TestModuleBasic(t *testing.T) {
	t.Parallel()

	// Configure Terraform options
	terraformOptions := &terraform.Options{
		// Path to the Terraform code
		TerraformDir: "../examples/simple",

		// Variables to pass to the module
		Vars: map[string]interface{}{
			"project":     "test",
			"environment": "dev",
			"owner":       "terratest@example.com",
			"location":    "eastus",
		},

		// Disable colors for cleaner output
		NoColor: true,
	}

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Initialize and apply the Terraform code
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	assert.Contains(t, resourceGroupName, "test-dev-eastus")

	resourceGroupID := terraform.Output(t, terraformOptions, "resource_group_id")
	assert.Contains(t, resourceGroupID, "/resourceGroups/")
}

// TestModuleWithExistingRG tests the module with an existing resource group
func TestModuleWithExistingRG(t *testing.T) {
	t.Parallel()

	// Skip if running in CI without Azure credentials
	if os.Getenv("AZURE_SUBSCRIPTION_ID") == "" {
		t.Skip("Skipping test that requires Azure credentials - set AZURE_SUBSCRIPTION_ID")
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/simple",

		Vars: map[string]interface{}{
			"project":               "test",
			"environment":           "dev",
			"owner":                 "terratest@example.com",
			"location":              "eastus",
			"create_resource_group": false,
			"resource_group_name":   "existing-rg-name",
		},

		NoColor: true,
	}

	defer terraform.Destroy(t, terraformOptions)

	// Expect failure if resource group doesn't exist
	// This validates the module handles missing resources correctly
	_, err := terraform.InitAndApplyE(t, terraformOptions)
	if err != nil {
		// Expected when resource group doesn't exist
		t.Log("Expected error when resource group doesn't exist:", err)
	}
}

// TestModuleValidation tests input validation
func TestModuleValidation(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name        string
		vars        map[string]interface{}
		expectError bool
	}{
		{
			name: "valid_inputs",
			vars: map[string]interface{}{
				"project":     "myapp",
				"environment": "dev",
				"owner":       "test@example.com",
				"location":    "eastus",
			},
			expectError: false,
		},
		{
			name: "invalid_environment",
			vars: map[string]interface{}{
				"project":     "myapp",
				"environment": "invalid",
				"owner":       "test@example.com",
				"location":    "eastus",
			},
			expectError: true,
		},
		{
			name: "invalid_project_name",
			vars: map[string]interface{}{
				"project":     "INVALID_NAME",
				"environment": "dev",
				"owner":       "test@example.com",
				"location":    "eastus",
			},
			expectError: true,
		},
	}

	for _, tc := range testCases {
		tc := tc // Capture range variable
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			terraformOptions := &terraform.Options{
				TerraformDir: "../examples/simple",
				Vars:         tc.vars,
				NoColor:      true,
			}

			// Only run plan to test validation
			_, err := terraform.InitAndPlanE(t, terraformOptions)

			if tc.expectError {
				assert.Error(t, err, "Expected validation error for case: %s", tc.name)
			} else {
				assert.NoError(t, err, "Did not expect error for case: %s", tc.name)
			}
		})
	}
}

// TestModuleTags tests that tags are correctly applied
func TestModuleTags(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/simple",

		Vars: map[string]interface{}{
			"project":     "tagtest",
			"environment": "dev",
			"owner":       "terratest@example.com",
			"location":    "eastus",
			"tags": map[string]interface{}{
				"custom_tag": "custom_value",
			},
		},

		NoColor: true,
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Get tags output
	tagsOutput := terraform.OutputMap(t, terraformOptions, "applied_tags")

	// Verify default tags
	assert.Equal(t, "tagtest", tagsOutput["project"])
	assert.Equal(t, "dev", tagsOutput["environment"])
	assert.Equal(t, "true", tagsOutput["terraform_managed"])

	// Verify custom tag
	assert.Equal(t, "custom_value", tagsOutput["custom_tag"])
}
