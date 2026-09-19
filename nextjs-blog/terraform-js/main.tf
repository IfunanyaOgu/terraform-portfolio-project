provider "aws" {
  region = "eu-west-2"
}


#s3 Bucket to store the state file
resource "aws_s3_bucket" "next_js_bucket" {
  bucket = "nextjs-portfolio-bucket-ify"
}

#ownership control
resource "aws_s3_bucket_ownersip_controls" "next_js_bucket_ownership_control" {
  bucket = aws_s3_bucket.next_js_bucket.id

  rule {
    object_ownership = "BucketOwnerPrefferred"
  }


}

#block public access
resource "aws_s3_bucket_public_access_block" "nextjs_bucket_public_access_block" {
    bucket = aws_s3_bucket.next_js_bucket.id

    block_public_acls =false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
}

#bucket ACL
resource "aws_s3_bucket_acl" "nextjs_bucket" {
    depends_on = [ 
        aws_s3_bucket_ownersip_controls.next_js,
        awaws_s3_bucket_public_access_block.nextjs_bucket_public_access_block 
        ]
        bucket = aws_s3_bucket.nextjs_bucket.id
  
}

#bucket policy
resource "aws_s3_bucket_policy" "nextjs_bucket_policy" {
    bucket = aws_s3_bucket.next_js_bucket.id

    policy = jsondecode (({
        version = "2012-10-17"
        statement = [
            {
                sid = "PublicReadGetObject"
                Effect = "Allow"
                Principal = "*"
                Action = "s3:GetObject"
                Resource = "${aws_s3_bucket.nextjs_bucket.arn}/*"
            }
        ]
    }))

}


#Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
    comment = "OAI for Next.JS portfolio site"
}

#Cloudfront distribution
resource "aws_cloudfront_distribution" "nextjs_distribution" {
  
  origin {
    domain_name = aws_s3_bucket.next_js_bucket.bucket_regional_domain_name
    origin_id = "s3-nextjs-portfolio-bucket"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity
    }
  }

  enabled = true
  is_ipv6_enabled = true
  comment = "Next.Js portfolio site"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods = ["GET","HEAD","OPTIONS"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = "s3-nextjs-portfolio-bucket"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400

  }
  restrictions {
    geo_restriction {
      restriction_type = none
    }
  }
  viewer_certificate {
    
  }

}