output "server_private_ip" {
  value       = aws_instance.k3s_server.private_ip
  description = "Private IP of the k3s server node"
}

output "agent_private_ip" {
  value       = aws_instance.k3s_agent.private_ip
  description = "Private IP of the k3s agent node"
}

output "cluster_token" {
  value       = random_password.cluster_token.result
  description = "Shared token used by server and agent (useful for debugging)"
  sensitive   = true
}
