import requests

headers = {
    "accept": "*/*",
    "accept-encoding": "gzip, deflate, br",
    "accept-language": "en-GB,en-US;q=0.9,en;q=0.8",
    "app-version": "1000000",
    "connection": "keep-alive",
    "content-type": "application/json",
    "dnt": "1",
    "host": "api.gotinder.com",
    "origin": "https://tinder.com",
    "platform": "web",
    "referer": "https://tinder.com",
    "user-agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.108 Safari/537.36"
    #"x-auth-token": "ABCDEFG"
}

payload = {
    "token": "EAAGm0PX4ZCpsBAGsc1m5TasJFaH8MQQiUy7MZCZBLTml7TL5YGgIm2mGpl4Djl6ZBMIrMZAAy7evZCyJ6lu4UW3upeygBIeZC9L3SimMCZCmMxu67657owM4V5GkXHsZCYHMs9B1JR5vB1PmYySZBRPZCO2T2DQd6oMm96K3LwpqAJ1NYuGnqx6X058"
}

r = requests.post("http://localhost:7777/v2/auth/login/facebook", headers=headers, json=payload)
print(r.json())
#r = requests.post("https://api.gotinder.com/v2/auth/login/facebook?locale=en-GB", headers=headers, json=payload)
print(r.json())
