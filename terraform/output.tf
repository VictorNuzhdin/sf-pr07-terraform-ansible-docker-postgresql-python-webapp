output "vm1_name_external_ip" {
  value       = "${yandex_compute_instance.host1.name}: ${yandex_compute_instance.host1.network_interface.0.nat_ip_address}"
  description = "The Name and public IP address of VM1 instance."
  sensitive   = false
}
