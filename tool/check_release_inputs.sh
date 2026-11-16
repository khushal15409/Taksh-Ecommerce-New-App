#!/usr/bin/env bash
# Pre-build check for release inputs. Never prints values, only file paths and key NAMES.
#
#   tool/check_release_inputs.sh [project_root]
#
# Fails when:
#  - a secret-bearing file is tracked by git (.env, key.properties, keystores, service-account JSON)
#  - .env (bundled into the app as a Flutter asset) holds anything but the client-side keys allowed below
#  - a pubspec asset path looks like a credential file
# A Google Maps/Places key is a client key (restrict it in Google Cloud Console), not a server secret.
set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"
ALLOWED_ENV_KEYS="GOOGLE_PLACES_API_KEY"
fail=0

if git rev-parse --git-dir >/dev/null 2>&1; then
  tracked=$(git ls-files | grep -E '(^|/)(\.env|key\.properties)$|\.(jks|keystore|p12|pem)$|service[-_]?account[^/]*\.json$' || true)
  if [ -n "$tracked" ]; then
    echo "ERROR: secret-bearing files are tracked by git:"; echo "$tracked" | sed 's/^/  - /'; fail=1
  fi
fi

if [ -f .env ]; then
  extra=""
  while IFS= read -r line; do
    line="${line#"${line%%[![:space:]]*}"}"
    case "$line" in ''|'#'*) continue ;; esac
    case "$line" in *=*) ;; *) continue ;; esac
    key="${line%%=*}"; key="${key#export }"; key="${key// /}"
    case " $ALLOWED_ENV_KEYS " in *" $key "*) ;; *) extra="$extra $key" ;; esac
  done < .env
  if [ -n "$extra" ]; then
    echo "ERROR: .env is bundled into the app but has non client-side keys:$extra (allowed: $ALLOWED_ENV_KEYS)"; fail=1
  fi
fi

assets=$(awk '/^flutter:/{f=1} f && /^[[:space:]]+-[[:space:]]/{print}' pubspec.yaml || true)
if echo "$assets" | grep -qiE 'service[-_]?account|credential|\.jks|\.keystore|\.pem|key\.properties'; then
  echo "ERROR: a pubspec asset looks like a credential file:"; echo "$assets" | grep -iE 'service[-_]?account|credential|\.jks|\.keystore|\.pem|key\.properties' | sed 's/^/  /'; fail=1
fi

if [ "$fail" -ne 0 ]; then exit 1; fi
echo "Release inputs OK (no tracked secret files, .env limited to: $ALLOWED_ENV_KEYS)"
