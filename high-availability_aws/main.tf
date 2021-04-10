provider "aws" {
  region = "ap-south-1"
}
resource "aws_security_group" "sg1" {
  name = "sg1"
  description = "Allow HTTP"
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
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Allow HTTP"
  }
}
resource "null_resource" "mykey" {
  provisioner "local-exec" {
    command = "aws ec2 create-key-pair --key-name ec2inskey --query 'KeyMaterial' --output text > mykeypair.pem"
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
  key_name = "ec2inskey"
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
  source = "ladders.jpg"
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
resource "aws_ebs_volume" "myvol" {
  depends_on = [aws_cloudfront_distribution.s3_distribution]
  availability_zone = "ap-south-1a"
  size = 10
}
resource "aws_volume_attachment" "ebsatt" {
  depends_on = [aws_ebs_volume.myvol]
  device_name = "/dev/sdh"
  instance_id = aws_instance.myins[0].id
  volume_id = aws_ebs_volume.myvol.id
  force_detach = true
}

resource "null_resource" "remote_acc" {
  depends_on = [null_resource.mykey]
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("./mykeypair.pem")
    host = aws_instance.myins[0].public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 /dev/xvdh",
      "sudo yum install httpd git -y",
      "sudo mount /dev/xvdh /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/RajitPaul11/terraform_aws.git /var/www/html/",
      "sudo mv /var/www/html/high-availability_aws/*.html /var/www/html",
      "sudo systemctl start httpd"
    ]
  }
}