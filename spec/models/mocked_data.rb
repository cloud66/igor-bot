require_relative './dynamic_stack.rb'

FIRST_STACK = {"uid"=>"327270243a9c6cb6eefa123ec55bde6f", "name"=>"pm-stagefirst-drupal",
               "git"=>nil, "git_branch"=>nil, "environment"=>"production", "cloud"=>"DigitalOcean",
               "fqdn"=>"pm-stage-drupal.stage.c66.me", "language"=>"ruby", "framework"=>"docker", "status"=>2,
               "health"=>3, "last_activity"=>"2016-10-20 10:32:10 UTC", "last_activity_iso"=>"2016-10-20T10:32:10Z",
               "maintenance_mode"=>false, "has_loadbalancer"=>false, "created_at"=>"2016-10-17T11:31:01Z",
               "updated_at"=>"2016-10-20T10:32:10Z", "deploy_directory"=>"/var/deploy/pm-stage-drupal",
               "cloud_status"=>"healthy", "is_busy"=>false,
               "redeploy_hook"=>"http://stage.cloud66.com/hooks/v1/stacks/redeploy/cooluidiscool/sweetuidissweet?services=drupal"}

SECOND_STACK = {"uid"=>"337270243a9c6cb6eefa123ec55bde6f", "name"=>"pm-stagesecond-drupal",
                "git"=>nil, "git_branch"=>nil, "environment"=>"production", "cloud"=>"DigitalOcean",
                "fqdn"=>"pm-stage-drupal.stage.c66.me", "language"=>"ruby", "framework"=>"docker", "status"=>2,
                "health"=>3, "last_activity"=>"2016-10-20 10:32:10 UTC", "last_activity_iso"=>"2016-10-20T10:32:10Z",
                "maintenance_mode"=>false, "has_loadbalancer"=>false, "created_at"=>"2016-10-17T11:31:01Z",
                "updated_at"=>"2016-10-20T10:32:10Z", "deploy_directory"=>"/var/deploy/pm-stage-drupal",
                "cloud_status"=>"healthy", "is_busy"=>false,
                "redeploy_hook"=>"http://stage.cloud66.com/hooks/v1/stacks/redeploy/cooluidiscool/sweetuidissweet?services=drupal"}

LAST_STACK = {"uid"=>"37270243a9c6cb6eefa123ec55bde6f", "name"=>"pm-stagelast-drupal",
              "git"=>nil, "git_branch"=>nil, "environment"=>"production", "cloud"=>"DigitalOcean",
              "fqdn"=>"pm-stage-drupal.stage.c66.me", "language"=>"ruby", "framework"=>"docker", "status"=>2,
              "health"=>3, "last_activity"=>"2016-10-20 10:32:10 UTC", "last_activity_iso"=>"2016-10-20T10:32:10Z",
              "maintenance_mode"=>false, "has_loadbalancer"=>false, "created_at"=>"2016-10-17T11:31:01Z",
              "updated_at"=>"2016-10-20T10:32:10Z", "deploy_directory"=>"/var/deploy/pm-stage-drupal",
              "cloud_status"=>"healthy", "is_busy"=>false,
              "redeploy_hook"=>"http://stage.cloud66.com/hooks/v1/stacks/redeploy/cooluidiscool/sweetuidissweet?services=drupal"}

GOOD_STACK = {"uid"=>"good_stack", "name"=>"pm-good_stack-drupal",
             "git"=>nil, "git_branch"=>nil, "environment"=>"production", "cloud"=>"DigitalOcean",
             "fqdn"=>"pm-stage-drupal.stage.c66.me", "language"=>"ruby", "framework"=>"docker", "status"=>2,
             "health"=>3, "last_activity"=>"2016-10-20 10:32:10 UTC", "last_activity_iso"=>"2016-10-20T10:32:10Z",
             "maintenance_mode"=>false, "has_loadbalancer"=>false, "created_at"=>"2016-10-17T11:31:01Z",
             "updated_at"=>"2016-10-20T10:32:10Z", "deploy_directory"=>"/var/deploy/pm-stage-drupal",
             "cloud_status"=>"healthy", "is_busy"=>false,
             "redeploy_hook"=>"http://stage.cloud66.com/hooks/v1/stacks/redeploy/cooluidiscool/sweetuidissweet?services=drupal"}

BUSY_STACK = {"uid"=>"busy_stack", "name"=>"pm-busy_stack-drupal",
             "git"=>nil, "git_branch"=>nil, "environment"=>"production", "cloud"=>"DigitalOcean",
             "fqdn"=>"pm-stage-drupal.stage.c66.me", "language"=>"ruby", "framework"=>"docker", "status"=>2,
             "health"=>3, "last_activity"=>"2016-10-20 10:32:10 UTC", "last_activity_iso"=>"2016-10-20T10:32:10Z",
             "maintenance_mode"=>false, "has_loadbalancer"=>false, "created_at"=>"2016-10-17T11:31:01Z",
             "updated_at"=>"2016-10-20T10:32:10Z", "deploy_directory"=>"/var/deploy/pm-stage-drupal",
             "cloud_status"=>"healthy", "is_busy"=>true,
             "redeploy_hook"=>"http://stage.cloud66.com/hooks/v1/stacks/redeploy/cooluidiscool/sweetuidissweet?services=drupal"}

BUSY_TO_GOOD_FOREVER_GOOD_STACK = {"uid"=>"good_to_good_forever_stack", "name"=>"good_to_good_forever_stack",
              "git"=>nil, "git_branch"=>nil, "environment"=>"production", "cloud"=>"DigitalOcean",
              "fqdn"=>"pm-stage-drupal.stage.c66.me", "language"=>"ruby", "framework"=>"docker", "status"=>2,
              "health"=>3, "last_activity"=>"2016-10-20 10:32:10 UTC", "last_activity_iso"=>"2016-10-20T10:32:10Z",
              "maintenance_mode"=>false, "has_loadbalancer"=>false, "created_at"=>"2016-10-17T11:31:01Z",
              "updated_at"=>"2016-10-20T10:32:10Z", "deploy_directory"=>"/var/deploy/pm-stage-drupal",
              "cloud_status"=>"healthy", "is_busy"=>false,
              "redeploy_hook"=>"http://stage.cloud66.com/hooks/v1/stacks/redeploy/cooluidiscool/sweetuidissweet?services=drupal"}

BUSY_TO_GOOD_FOREVER_BUSY_STACK = {"uid"=>"busy_to_good_forever_stack_wait_loop", "name"=>"busy_to_good_forever_stack_wait_loop",
              "git"=>nil, "git_branch"=>nil, "environment"=>"production", "cloud"=>"DigitalOcean",
              "fqdn"=>"pm-stage-drupal.stage.c66.me", "language"=>"ruby", "framework"=>"docker", "status"=>2,
              "health"=>3, "last_activity"=>"2016-10-20 10:32:10 UTC", "last_activity_iso"=>"2016-10-20T10:32:10Z",
              "maintenance_mode"=>false, "has_loadbalancer"=>false, "created_at"=>"2016-10-17T11:31:01Z",
              "updated_at"=>"2016-10-20T10:32:10Z", "deploy_directory"=>"/var/deploy/pm-stage-drupal",
              "cloud_status"=>"healthy", "is_busy"=>true,
              "redeploy_hook"=>"http://stage.cloud66.com/hooks/v1/stacks/redeploy/cooluidiscool/sweetuidissweet?services=drupal"}

BUSY_TO_GOOD_FOREVER_BUSY_STACK_SET_LOCAL_STATUS_TO_CANCELLING_GOOD = {"uid"=>"busy_to_good_forever_stack_set_local_status_to_cancelling_good", "name"=>"busy_to_good_forever_stack_set_local_status_to_cancelling_good",
             "git"=>nil, "git_branch"=>nil, "environment"=>"production", "cloud"=>"DigitalOcean",
             "fqdn"=>"pm-stage-drupal.stage.c66.me", "language"=>"ruby", "framework"=>"docker", "status"=>2,
             "health"=>3, "last_activity"=>"2016-10-20 10:32:10 UTC", "last_activity_iso"=>"2016-10-20T10:32:10Z",
             "maintenance_mode"=>false, "has_loadbalancer"=>false, "created_at"=>"2016-10-17T11:31:01Z",
             "updated_at"=>"2016-10-20T10:32:10Z", "deploy_directory"=>"/var/deploy/pm-stage-drupal",
             "cloud_status"=>"healthy", "is_busy"=>false,
             "redeploy_hook"=>"http://stage.cloud66.com/hooks/v1/stacks/redeploy/cooluidiscool/sweetuidissweet?services=drupal"}

BUSY_TO_GOOD_FOREVER_BUSY_STACK_SET_LOCAL_STATUS_TO_CANCELLING_BUSY = {"uid"=>"busy_to_good_forever_stack_set_local_status_to_cancelling_busy", "name"=>"busy_to_good_forever_stack_set_local_status_to_cancelling_busy",
              "git"=>nil, "git_branch"=>nil, "environment"=>"production", "cloud"=>"DigitalOcean",
              "fqdn"=>"pm-stage-drupal.stage.c66.me", "language"=>"ruby", "framework"=>"docker", "status"=>2,
              "health"=>3, "last_activity"=>"2016-10-20 10:32:10 UTC", "last_activity_iso"=>"2016-10-20T10:32:10Z",
              "maintenance_mode"=>false, "has_loadbalancer"=>false, "created_at"=>"2016-10-17T11:31:01Z",
              "updated_at"=>"2016-10-20T10:32:10Z", "deploy_directory"=>"/var/deploy/pm-stage-drupal",
              "cloud_status"=>"healthy", "is_busy"=>true,
              "redeploy_hook"=>"http://stage.cloud66.com/hooks/v1/stacks/redeploy/cooluidiscool/sweetuidissweet?services=drupal"}

STACK_STARTED_REDEPLOY_QUEUED_FALSE = {"ok"=>true, "message"=>"Stack starting redeployment", "queued"=>false}

STACK_STARTED_REDEPLOY_QUEUED_TRUE = {"ok"=>true, "message"=>"Stack starting redeployment", "queued"=>true}

SERVICES_FROM_STACK = [{"name"=>"ubuntu", "containers"=>[{"uid"=>"0963edd340ba6569da46024886d6a00b7a6a3834fba9bf38b4626502bfd0ac5f", "name"=>"ubuntu.ambitious-unassuming-otter", "server_uid"=>"4e452d775c481a8157dc43d7556d5430", "server_name"=>"Bison", "service_name"=>"ubuntu", "image"=>"ubuntu", "command"=>"sleep 10000", "started_at"=>"2016-10-28T16:43:39Z", "ports"=>[], "private_ip"=>"25.0.0.11", "docker_ip"=>"172.17.0.4", "health_state"=>0, "health_message"=>nil, "health_source"=>nil, "capture_output"=>true, "restart_on_deploy"=>true, "created_at"=>"2016-10-28T16:43:44Z", "updated_at"=>"2016-10-28T20:22:21Z", "status"=>"started"}], "source_type"=>"image", "git_ref"=>"", "image_name"=>"", "image_uid"=>"", "image_tag"=>"", "command"=>"sleep 10000", "build_command"=>nil, "deploy_command"=>nil, "wrap_command"=>""},
                       {"name"=>"nginx", "containers"=>[{"uid"=>"8e4e23426367124d43d89a1a9098e2727ec1ae65c64c46083e2b22476489b96e", "name"=>"nginx.loyal-good-kangaroo", "server_uid"=>"4e452d775c481a8157dc43d7556d5430", "server_name"=>"Bison", "service_name"=>"nginx", "image"=>"nginx", "command"=>nil, "started_at"=>"2016-10-28T16:47:33Z", "ports"=>[{"container"=>80, "http"=>80, "https"=>443}], "private_ip"=>"25.0.0.97", "docker_ip"=>"172.17.0.3", "health_state"=>0, "health_message"=>nil, "health_source"=>nil, "capture_output"=>true, "restart_on_deploy"=>true, "created_at"=>"2016-10-28T16:47:39Z", "updated_at"=>"2016-10-28T20:22:21Z", "status"=>"started"}], "source_type"=>"image", "git_ref"=>"", "image_name"=>"", "image_uid"=>"", "image_tag"=>"", "command"=>nil, "build_command"=>nil, "deploy_command"=>nil, "wrap_command"=>""}]




# BTGFS1 = BUSY_STACK
# BTGFS2 = GOOD_STACK
# BTGFS1["uid"] = "busy_to_good_forever_stack"
# BTGFS1["name"] = "busy_to_good_forever_stack"
# BTGFS2["uid"] = "busy_to_good_forever_stack"
# BTGFS2["name"] = "busy_to_good_forever_stack"

#BTGFS1["uid"] = BTGFS1["name"] = BTGFS2["uid"] = BTGFS1["name"] = "busy_to_good_forever_stack"


BUSY_TO_GOOD_FOREVER_STACK = DynamicStack.new([BUSY_TO_GOOD_FOREVER_BUSY_STACK, BUSY_TO_GOOD_FOREVER_GOOD_STACK], true)
BUSY_TO_GOOD_FOREVER_STACK_SET_LOCAL_STATUS = DynamicStack.new([BUSY_TO_GOOD_FOREVER_BUSY_STACK_SET_LOCAL_STATUS_TO_CANCELLING_BUSY, BUSY_TO_GOOD_FOREVER_BUSY_STACK_SET_LOCAL_STATUS_TO_CANCELLING_GOOD], true)
