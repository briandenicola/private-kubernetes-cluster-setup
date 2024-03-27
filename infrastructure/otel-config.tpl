receivers:
    zipkin:
        endpoint: 0.0.0.0:9411
extensions:
    health_check:
    pprof:
        endpoint: :1888
    zpages:
        endpoint: :55679
exporters:
    logging:
        loglevel: debug
    azuremonitor:
        endpoint: "https://dc.services.visualstudio.com/v2/track"
        instrumentation_key: ${app_insight_key}
        maxbatchsize: 100
        maxbatchinterval: 10s
service:
    extensions: [pprof, zpages, health_check]
    pipelines:
        traces:
            receivers: [zipkin]
            exporters: [azuremonitor,logging]
