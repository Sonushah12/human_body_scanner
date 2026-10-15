#!/usr/bin/env python3
"""Apply the cloud's non-secret proxy endpoints to a local Gradle cache.

Keep JVM TLS verification and the inherited session trust. No credential values
are inspected or copied. Existing unrelated Gradle properties are preserved.
"""
import json
import os
from pathlib import Path
from urllib.parse import urlsplit

policy=Path('/etc/codex/network-policy.json')
if not policy.exists():
    raise SystemExit(0)
proxy=urlsplit(json.loads(policy.read_text())['http_proxy'])
root=Path(os.environ.get('GRADLE_USER_HOME','/workspace/.gradle'))
root.mkdir(parents=True,exist_ok=True)
path=root/'gradle.properties'
existing=path.read_text() if path.exists() else ''
keys=['systemProp.http.proxyHost','systemProp.http.proxyPort','systemProp.https.proxyHost','systemProp.https.proxyPort','systemProp.http.nonProxyHosts']
lines=[line for line in existing.splitlines() if not any(line.startswith(key+'=') for key in keys)]
lines += [
    'systemProp.http.proxyHost='+proxy.hostname,
    'systemProp.http.proxyPort='+str(proxy.port),
    'systemProp.https.proxyHost='+proxy.hostname,
    'systemProp.https.proxyPort='+str(proxy.port),
    'systemProp.http.nonProxyHosts=localhost|127.*',
]
path.write_text('\n'.join(lines)+'\n')
print('Configured Gradle to use the cloud session proxy; TLS verification retained.')
