import urllib.request
import json
import urllib.parse
import ssl

context = ssl._create_unverified_context()

# Use urlencode or just quote for path parameters
pt_id = urllib.parse.quote("7kIyza84OTIiczLYR7dfJ8T6oxlpwGP8jFLm8XGIN4uwNFW3tlOx_dUR1KX_biZ6IRKW7A==")
prodi_id = urllib.parse.quote("nU34AraIat-iKWSCYNFy6DSiooCyETAtUEi51-V4HuwSdWpm77nX629-HKRpZUbpLJM6QA==")
dosen_id = urllib.parse.quote("t9liimncjdzQPuu6o73jLPtCMpbSAWPq-ST2JWm0ZBDD_hV3RgFPaFFKSK1tKFldujC25A==")
mhs_id = urllib.parse.quote("4AVc4EJf1KYJjI9HizfG5uNPVUVoBp7_mVNqB-onRh6062O4FZo-yY4fJt4OPifJX7gplw==")

headers = {
    "Accept": "application/json, text/plain, */*",
    "Host": "api-pddikti.kemdiktisaintek.go.id",
    "Origin": "https://pddikti.kemdiktisaintek.go.id",
    "Referer": "https://pddikti.kemdiktisaintek.go.id/",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
    "X-User-IP": "103.47.132.29",
}

endpoints = {
    "PT Detail": f"https://api-pddikti.kemdiktisaintek.go.id/pt/detail/{pt_id}",
    "Prodi Detail": f"https://api-pddikti.kemdiktisaintek.go.id/prodi/detail/{prodi_id}",
    "Prodi Desc": f"https://api-pddikti.kemdiktisaintek.go.id/prodi/desc/{prodi_id}",
    "Dosen Profile": f"https://api-pddikti.kemdiktisaintek.go.id/dosen/profile/{dosen_id}",
    "Dosen Study History": f"https://api-pddikti.kemdiktisaintek.go.id/dosen/study-history/{dosen_id}",
    "Dosen Teaching History": f"https://api-pddikti.kemdiktisaintek.go.id/dosen/teaching-history/{dosen_id}",
    "Mhs Detail": f"https://api-pddikti.kemdiktisaintek.go.id/detail/mhs/{mhs_id}",
}

for name, url in endpoints.items():
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, context=context) as response:
            html = response.read().decode('utf-8')
            data = json.loads(html)
            print(f"\n--- {name} Success ---")
            if isinstance(data, dict):
                print("Keys:", data.keys())
                # Print key attributes
                for k in list(data.keys())[:10]:
                    print(f"  {k}: {str(data[k])[:100]}")
            elif isinstance(data, list):
                print(f"List length: {len(data)}")
                if data:
                    print("First item keys:", data[0].keys() if isinstance(data[0], dict) else type(data[0]))
                    if isinstance(data[0], dict):
                        for k, v in data[0].items():
                            print(f"  {k}: {str(v)[:100]}")
            else:
                print("Type:", type(data))
    except Exception as e:
        print(f"Error {name}: {e}")

