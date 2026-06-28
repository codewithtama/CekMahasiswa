import urllib.request
import json

url = "https://api-pddikti.kemdiktisaintek.go.id/pencarian/all/informatika"
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
        html = response.read().decode('utf-8')
        data = json.loads(html)
        print("Success! Keys in response:", data.keys() if isinstance(data, dict) else type(data))
        if isinstance(data, dict):
            for k in list(data.keys())[:5]:
                print(f"Key '{k}' type:", type(data[k]))
                if isinstance(data[k], list) and len(data[k]) > 0:
                    print(f"Sample item from '{k}':", data[k][0])
        elif isinstance(data, list) and len(data) > 0:
            print("Sample item:", data[0])
except Exception as e:
    print(f"Error: {e}")
