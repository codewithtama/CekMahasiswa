import urllib.request
import json
import ssl

context = ssl._create_unverified_context()

raw_id = "7kIyza84OTIiczLYR7dfJ8T6oxlpwGP8jFLm8XGIN4uwNFW3tlOx_dUR1KX_biZ6IRKW7A=="

paths = [
    f"https://api-pddikti.kemdiktisaintek.go.id/detail/pt/{raw_id}",
    f"https://api-pddikti.kemdiktisaintek.go.id/pt/detail/{raw_id}",
    f"https://api-pddikti.kemdiktisaintek.go.id/pt/{raw_id}",
    f"https://api-pddikti.kemdiktisaintek.go.id/detail/universitas/{raw_id}",
]

headers = {
    "Accept": "application/json, text/plain, */*",
    "Host": "api-pddikti.kemdiktisaintek.go.id",
    "Origin": "https://pddikti.kemdiktisaintek.go.id",
    "Referer": "https://pddikti.kemdiktisaintek.go.id/",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
    "X-User-IP": "103.47.132.29",
}

for url in paths:
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, context=context) as response:
            html = response.read().decode('utf-8')
            data = json.loads(html)
            print(f"SUCCESS: {url}")
            print("Keys:", list(data.keys())[:5])
    except Exception as e:
        print(f"FAIL: {url} - {e}")

