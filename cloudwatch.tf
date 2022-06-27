data "aws_instances" "test" {
  instance_state_names = ["running", "stopped"]
}
 output "ec2s" {
   value = [for i in data.aws_instances.test.ids : i]
 }

locals {
  instances_ids = [for i in data.aws_instances.test.ids : i]
}
locals {
  ec2ids = [for i in local.instances_ids :
        {
        type: "metric",
        x: 0,
        y: 0,
        width: 12,
        height: 6,
        properties: {
            metrics: [
                ["AWS/EC2", "CPUUtilization", "InstanceId", i]
            ]
            period: 300,
            stat: "Average",
            region: "us-east-1",
            title: "EC2 Instance CPU ${i}"
        }
        }
        ]
}
resource "aws_cloudwatch_dashboard" "ec2util" {
  dashboard_name = "ec2util"

  dashboard_body = jsonencode({ 
  widgets: concat(local.ec2ids, [{
    type: "metric",
            x: 0,
            y: 0,
            width: 6,
            height: 3,
            properties: {
                metrics: [
                    [ "AWS/ECS", "CPUUtilization", "ServiceName", "${aws_ecs_service.ghost.name}", "ClusterName", "${aws_ecs_cluster.ghost.name}", { "label": "Running Tasks Count" } ]
                ],
                sparkline: true,
                view: "singleValue",
                region: "us-east-1",
                stat: "SampleCount",
                period: 60,
                title: "Running Tasks Count"
            }
  },
  {
    type: "metric",
    x: 6,
    y: 0,
    width: 6,
    height: 3,
    properties: {
        metrics: [
            [ "ECS/ContainerInsights", "CpuUtilized", "ServiceName", "${aws_ecs_service.ghost.name}", "ClusterName", "${aws_ecs_cluster.ghost.name}", { "label": "Service CPU Utilization" } ]
        ],
        sparkline: true,
        view: "singleValue",
        region: "us-east-1",
        title: "Service CPU Utilization",
        period: 60,
        stat: "Average"
    }
  },
  {
    type: "metric",
    x: 0,
    y: 0,
    width: 6,
    height: 3,
    properties: {
        metrics: [
            [ "AWS/EFS", "ClientConnections", "FileSystemId", "${aws_efs_file_system.ghost_content.id}" ]
        ],
        sparkline: true,
        view: "singleValue",
        region: "us-east-1",
        stat: "Average",
        period: 60
    }
    },
  {
    type: "metric",
    x: 6,
    y: 0,
    width: 18,
    height: 3,
    properties: {
        sparkline: true,
        view: "singleValue",
        metrics: [
            [ "AWS/EFS", "StorageBytes", "StorageClass", "Standard", "FileSystemId", "${aws_efs_file_system.ghost_content.id}" ],
            [ "...", "IA", ".", "." ],
            [ "...", "Total", ".", "." ]
        ],
        region: "us-east-1"
    }
  },
  {
        type: "metric",
        x: 0,
        y: 0,
        width: 6,
        height: 3,
        properties: {
            metrics: [
                [ "AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "${aws_db_instance.cloudx.identifier}" ]
            ],
            sparkline: true,
            view: "singleValue",
            region: "us-east-1",
            stat: "Average",
            period: 60
        }
    },
    {
        type: "metric",
        x: 6,
        y: 0,
        width: 6,
        height: 3,
        properties: {
            sparkline: true,
            view: "singleValue",
            metrics: [
                [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${aws_db_instance.cloudx.identifier}" ]
            ],
            region: "us-east-1",
            period: 60
        }
    },
    {
        type: "metric",
        x: 12,
        y: 0,
        width: 12,
        height: 3,
        properties: {
            sparkline: true,
            view: "singleValue",
            metrics: [
                [ "AWS/RDS", "ReadIOPS", "DBInstanceIdentifier", "${aws_db_instance.cloudx.identifier}" ],
                [ ".", "WriteIOPS", ".", "." ]
            ],
            region: "us-east-1",
            period: 60
        }
    }])
  })
}


# resource "aws_cloudwatch_dashboard" "ecsutil" {
#     #Service CPU Utilization
#     #Running Tasks Count
#   dashboard_name = "ecsutil"

#   dashboard_body = <<EOF
# {
#     "widgets": [
#         {
#             "type": "metric",
#             "x": 0,
#             "y": 0,
#             "width": 6,
#             "height": 3,
#             "properties": {
#                 "metrics": [
#                     [ "AWS/ECS", "CPUUtilization", "ServiceName", "${aws_ecs_service.ghost.name}", "ClusterName", "${aws_ecs_cluster.ghost.name}", { "label": "Running Tasks Count" } ]
#                 ],
#                 "sparkline": true,
#                 "view": "singleValue",
#                 "region": "us-east-1",
#                 "stat": "SampleCount",
#                 "period": 60,
#                 "title": "Running Tasks Count"
#             }
#         },
#         {
#             "type": "metric",
#             "x": 6,
#             "y": 0,
#             "width": 6,
#             "height": 3,
#             "properties": {
#                 "metrics": [
#                     [ "ECS/ContainerInsights", "CpuUtilized", "ServiceName", "${aws_ecs_service.ghost.name}", "ClusterName", "${aws_ecs_cluster.ghost.name}", { "label": "Service CPU Utilization" } ]
#                 ],
#                 "sparkline": true,
#                 "view": "singleValue",
#                 "region": "us-east-1",
#                 "title": "Service CPU Utilization",
#                 "period": 60,
#                 "stat": "Average"
#             }
#         }
#     ]
# }
# EOF
# }

# resource "aws_cloudwatch_dashboard" "efsutil" {
#   dashboard_name = "efsutil"

#   dashboard_body = <<EOF
# {
#     "widgets": [
#         {
#             "type": "metric",
#             "x": 0,
#             "y": 0,
#             "width": 6,
#             "height": 3,
#             "properties": {
#                 "metrics": [
#                     [ "AWS/EFS", "ClientConnections", "FileSystemId", "${aws_efs_file_system.ghost_content.id}" ]
#                 ],
#                 "sparkline": true,
#                 "view": "singleValue",
#                 "region": "us-east-1",
#                 "stat": "Average",
#                 "period": 60
#             }
#         },
#         {
#             "type": "metric",
#             "x": 6,
#             "y": 0,
#             "width": 18,
#             "height": 3,
#             "properties": {
#                 "sparkline": true,
#                 "view": "singleValue",
#                 "metrics": [
#                     [ "AWS/EFS", "StorageBytes", "StorageClass", "Standard", "FileSystemId", "${aws_efs_file_system.ghost_content.id}" ],
#                     [ "...", "IA", ".", "." ],
#                     [ "...", "Total", ".", "." ]
#                 ],
#                 "region": "us-east-1"
#             }
#         }
#     ]
# }
# EOF
# }

# resource "aws_cloudwatch_dashboard" "rdsutil" {
#   dashboard_name = "rdsutil"

#   dashboard_body = <<EOF
# {
#     "widgets": [
#         {
#             "type": "metric",
#             "x": 0,
#             "y": 0,
#             "width": 6,
#             "height": 3,
#             "properties": {
#                 "metrics": [
#                     [ "AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "${aws_db_instance.cloudx.identifier}" ]
#                 ],
#                 "sparkline": true,
#                 "view": "singleValue",
#                 "region": "us-east-1",
#                 "stat": "Average",
#                 "period": 60
#             }
#         },
#         {
#             "type": "metric",
#             "x": 6,
#             "y": 0,
#             "width": 6,
#             "height": 3,
#             "properties": {
#                 "sparkline": true,
#                 "view": "singleValue",
#                 "metrics": [
#                     [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${aws_db_instance.cloudx.identifier}" ]
#                 ],
#                 "region": "us-east-1",
#                 "period": 60
#             }
#         },
#         {
#             "type": "metric",
#             "x": 12,
#             "y": 0,
#             "width": 12,
#             "height": 3,
#             "properties": {
#                 "sparkline": true,
#                 "view": "singleValue",
#                 "metrics": [
#                     [ "AWS/RDS", "ReadIOPS", "DBInstanceIdentifier", "${aws_db_instance.cloudx.identifier}" ],
#                     [ ".", "WriteIOPS", ".", "." ]
#                 ],
#                 "region": "us-east-1",
#                 "period": 60
#             }
#         }
#     ]
# }
# EOF
# }