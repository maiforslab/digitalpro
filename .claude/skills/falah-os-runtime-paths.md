When working on Falah OS container config, service startup, or Dockerfile:

The CasaOS-Common library (indirect dependency of all four services) hardcodes:
  DefaultConfigPath  = /etc/casaos
  DefaultRuntimePath = /var/run/casaos
  DefaultDataPath    = /var/lib/casaos

Rules:
- Gateway config MUST be at /etc/casaos/gateway.ini (no -c flag; hardcoded path)
- RuntimePath in ALL configs MUST be /var/run/casaos (shared inter-service coordination)
- entrypoint.sh patches /etc/casaos/gateway.ini (not /etc/falahos/) for PORT injection
- entrypoint.sh waits on /var/run/casaos/message-bus.url and /var/run/casaos/management.url
- Data paths (/var/lib/falahos/...) are safe to customize via -c flag configs

Violation symptoms: container starts but services can't find each other (startup deadlock).
