output "some_hardcoded_output" {
  // Hard coded value
  value = "some value hard coded"
}

output "some_sfn_output" {
  value = "${aws_sfn_state_machine.some_identifier.status}"
}
