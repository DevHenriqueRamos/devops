resource "aws_s3_bucket" "beanstalk_deploys" {
  bucket = "${var.name}-deploys"
}

resource "aws_s3_object" "docker" {
  depends_on = [aws_s3_bucket.beanstalk_deploys]

  bucket = "${var.name}-deploys"
  key    = "${var.name}.zip"
  source = "${var.name}.zip"
  etag   = filemd5("${var.name}.zip")
}
