resource "aws_volume_attachment" "ebsattach" {
  depends_on = [aws_ebs_volume.ebsvol]
  device_name = "/dev/sdh"
  instance_id = "${ aws_instance.ec2ins.id }"
  volume_id = "${aws_ebs_volume.ebsvol.id}"
}