output "loadbalancer_url" {
  value = "${aws_alb.main.dns_name}"
}

output "cluster_name" {
  value = "${aws_ecs_cluster.main.name}"
}

output "cluster_id" {
  value = "${aws_ecs_cluster.main.id}"
}

output "alb_listener_arn" {
  value = "${aws_alb_listener.front_end.arn}"
}

output "target_group_arn" {
  value = "${aws_alb_target_group.app.arn}"
}




