# The "setup" test:
# - loads terraform.tf to set the required versions for following tests
# - to prepare dependencies to be used in the remote module tests
run "setup" {
  command = plan

  module {
    source = "./tests/remote"
  }
}
