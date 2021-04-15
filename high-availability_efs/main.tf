provider "aws" {
  region = "ap-south-1"
}
resource "aws_security_group" "sg1" {
  name = "sg1"
  description = "Allow HTTP & NFS"
  vpc_id = "vpc-5bedf033"
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 2049
    protocol = "tcp"
    to_port = 2049
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Allow HTTP, SSH, NFS"
  }
}
resource "null_resource" "mykey" {
  provisioner "local-exec" {
    command = "aws ec2 create-key-pair --key-name ec2key --query 'KeyMaterial' --output text > mykeypair.pem"
  }
}
resource "aws_instance" "myins" {
  ami = "ami-0bcf5425cdc1d8a85"
  instance_type = "t2.micro"
  availability_zone = "ap-south-1a"
  count = 1
  tags = {
    Name = "Web"
  }
  vpc_security_group_ids = [aws_security_group.sg1.id]
  key_name = "ec2key"
  depends_on = [aws_security_group.sg1]
}

resource "aws_s3_bucket" "mybucket" {
  acl = "public-read"
  bucket = "my-t3st-buck3t"

  tags = {
    Name = "My Bucket"
  }
  depends_on = [aws_instance.myins]
}
resource "aws_s3_bucket_object" "myobj" {
  bucket = aws_s3_bucket.mybucket.id
  key = "myimg"
  source = "manutd.jpg"
  acl = "public-read"
  content_type = "image/jpg"
  depends_on = [aws_s3_bucket.mybucket]
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = [aws_s3_bucket_object.myobj]
  origin {
    domain_name = "${aws_s3_bucket.mybucket.bucket}.s3.amazonaws.com"
    origin_id = "S3.${aws_s3_bucket.mybucket.bucket}"
  }
  enabled = true
  default_cache_behavior {
    allowed_methods = ["HEAD", "GET"]
    cached_methods = ["HEAD", "GET"]
    target_origin_id = "S3.${aws_s3_bucket.mybucket.bucket}"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    default_ttl = 0
    max_ttl = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_efs_file_system" "myefs" {
  tags = {
    Name = "My Product"
  }
}

resource "aws_efs_mount_target" "myefsmount1" {
  depends_on = [aws_efs_file_system.myefs]
  file_system_id = aws_efs_file_system.myefs.id
  subnet_id      = "subnet-01fcc669"
  security_groups = [aws_security_group.sg1.id]
}

resource "null_resource" "null_local1" {
  depends_on = [aws_efs_mount_target.myefsmount1]
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("./mykeypair.pem")
    host = aws_instance.myins[0].public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install git httpd -y",
      "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-eb0b253a.efs.ap-south-1.amazonaws.com:/ /var/www/html/",
      "sudo git clone https://github.com/RajitPaul11/terraform_aws.git /var/www/html",
      "sudo mv /var/www/html/high-availability_efs/* /var/www/html/",
      "sudo systemctl start httpd"
    ]
  }
}