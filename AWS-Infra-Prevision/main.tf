

data "aws_availability_zones" "available" {}

resource "aws_vpc" "todo_VPC" {
    cidr_block       = "10.0.0.0/16"
    enable_dns_hostnames = true
    tags = {
        Name = "${var.TagName}"
    }
}

resource "aws_subnet" "todo_subnet" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.todo_VPC.id}"

  tags = {
        Name = "${var.TagName}"
    }

}


resource "aws_internet_gateway" "IGtodo" {
  vpc_id = "${aws_vpc.todo_VPC.id}"

  tags = {
    Name = "${var.TagName}"
  }
}

resource "aws_route_table" "RTtodo" {
  vpc_id = "${aws_vpc.todo_VPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.IGtodo.id}"
  }
}

resource "aws_route_table_association" "RTAtodo" {
  count = 2

  subnet_id      = "${aws_subnet.todo_subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.RTtodo.id}"
}



resource "aws_iam_role" "todo-cluster" {
  name = "eks-demo-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "todo-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.todo-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "todo-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.todo-cluster.name}"
}


resource "aws_security_group" "todo-cluster" {
  name        = "eks-todo-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.todo_VPC.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.TagName}"
  }
}

# OPTIONAL: Allow inbound traffic from your local workstation external IP
#           to the Kubernetes. You will need to replace A.B.C.D below with
#           your real IP. Services like icanhazip.com can help you find this.
resource "aws_security_group_rule" "todo-cluster-ingress-workstation-https" {
  cidr_blocks       = ["94.58.137.198/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.todo-cluster.id}"
  to_port           = 443
  type              = "ingress"
}


resource "aws_eks_cluster" "todo" {
  name            = "${var.ClusterName}"
  role_arn        = "${aws_iam_role.todo-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.todo-cluster.id}"]
    subnet_ids         = flatten(["${aws_subnet.todo_subnet.*.id}"])
  }

  depends_on = [
    "aws_iam_role_policy_attachment.todo-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.todo-cluster-AmazonEKSServicePolicy",
  ]
}