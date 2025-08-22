import os

import requests

MENDER_PAT_ENV_KEY = 'MENDER_PAT'
MENDER_HOST_ENV_KEY = 'MENDER_HOST'
TENANT_TOKEN_ENV_KEY = 'TENANT_TOKEN'

if TENANT_TOKEN_ENV_KEY in os.environ:
  print(os.getenv(TENANT_TOKEN_ENV_KEY))
elif MENDER_PAT_ENV_KEY in os.environ:
  mender_host = os.getenv(MENDER_HOST_ENV_KEY, 'https://hosted.mender.io')
  r = requests.get(
    f'{mender_host}/api/management/v1/tenantadm/user/tenant',
    headers = {
      'Accept': '*/*',
      'Authorization': f'Bearer {os.getenv(MENDER_PAT_ENV_KEY)}'
    }
  )
  if r.status_code != 200:
    print(
      f'Tenant token get request failed: status={r.status_code}, text={r.text}, url={r.request.url}, headers={r.request.headers}'
    )
    r.raise_for_status()
  else:
    print(r.json()['tenant_token'])
else:
  raise ValueError('No Mender authentication configured.')
