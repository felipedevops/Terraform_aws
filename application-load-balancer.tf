resource "aws_alb" "alb" {
  name            = "${var.infra_env}-devops-alb"
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = ["${aws_subnet.PrivateSubnet4.id}", "${aws_subnet.PublicSubnet1.id}"]
  #tags { "${aws_subnet.PrivateSubnet3.id}", , "${aws_subnet.PublicSubnet1.id}"
  #  Name = "terraform-${var.infra_env}-alb"
  #}
}