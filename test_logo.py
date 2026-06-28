import urllib.request

raw_id = "7kIyza84OTIiczLYR7dfJ8T6oxlpwGP8jFLm8XGIN4uwNFW3tlOx_dUR1KX_biZ6IRKW7A=="
url = f"https://api-pddikti.kemdiktisaintek.go.id/pt/logo/{raw_id}"

headers = {
    "Accept": "application/json, text/plain, */*",
    "Host": "api-pddikti.kemdiktisaintek.go.id",
    "Origin": "https://pddikti.kemdiktisaintek.go.id",
    "Referer": "https://pddikti.kemdiktisaintek.go.id/",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
    "X-User-IP": "103.47.132.29",
}

req = urllib.request.Request(url, headers=headers)
try:
    with urllib.request.urlopen(req) as response:
        content_type = response.headers.get('content-type', '')
        content = response.read()
        print("Success!")
        print("Content Type:", content_type)
        print("Content Length:", len(content))
        print("Sample:", content[:100])
except Exception as e:
    print(f"Error: {e}")
