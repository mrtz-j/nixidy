{
  lib,
  config,
  ...
}: let
  apps = config.applications;
in {
  # Create an application with a helm chart
  # with `extraOpts` set
  applications.test1.helm.releases.test1 = {
    chart = ./chart;
    extraOpts = ["--no-hooks"];
  };

  test = with lib; {
    name = "helm chart with extra opts";
    description = "Create an application with Helm chart and adding extra opts.";
    assertions = [
      {
        description = "Deployment should be rendered correctly.";

        expression =
          findFirst
          (x: x.kind == "Deployment" && x.metadata.name == "test1-chart")
          null
          apps.test1.objects;

        expected = {
          apiVersion = "apps/v1";
          kind = "Deployment";
          metadata = {
            name = "test1-chart";
            namespace = "test1";
            labels = {
              "app.kubernetes.io/instance" = "test1";
              "app.kubernetes.io/managed-by" = "Helm";
              "app.kubernetes.io/name" = "chart";
              "app.kubernetes.io/version" = "1.16.0";
              "helm.sh/chart" = "chart-0.1.0";
            };
          };
          spec = {
            replicas = 1;
            selector.matchLabels = {
              "app.kubernetes.io/instance" = "test1";
              "app.kubernetes.io/name" = "chart";
            };
            template = {
              metadata.labels = {
                "app.kubernetes.io/instance" = "test1";
                "app.kubernetes.io/managed-by" = "Helm";
                "app.kubernetes.io/name" = "chart";
                "app.kubernetes.io/version" = "1.16.0";
                "helm.sh/chart" = "chart-0.1.0";
              };
              spec.containers = [
                {
                  name = "chart";
                  image = "nginx:latest";
                  ports = [
                    {
                      name = "http";
                      containerPort = 80;
                      protocol = "TCP";
                    }
                  ];
                }
              ];
            };
          };
        };
      }

      {
        description = "Service should be rendered correctly.";

        expression =
          findFirst
          (x: x.kind == "Service" && x.metadata.name == "test1-chart")
          null
          apps.test1.objects;

        expected = {
          apiVersion = "v1";
          kind = "Service";
          metadata = {
            name = "test1-chart";
            namespace = "test1";
            labels = {
              "app.kubernetes.io/instance" = "test1";
              "app.kubernetes.io/managed-by" = "Helm";
              "app.kubernetes.io/name" = "chart";
              "app.kubernetes.io/version" = "1.16.0";
              "helm.sh/chart" = "chart-0.1.0";
            };
          };
          spec = {
            type = "ClusterIP";
            ports = [
              {
                port = 80;
                targetPort = "http";
                protocol = "TCP";
                name = "http";
              }
            ];
            selector = {
              "app.kubernetes.io/instance" = "test1";
              "app.kubernetes.io/name" = "chart";
            };
          };
        };
      }

      {
        description = "Job hook should not be rendered at all.";

        expression =
          findFirst
          (x: x.kind == "Job" && x.metadata.name == "job-hook")
          null
          apps.test1.objects;

        expected = null;
      }
    ];
  };
}
