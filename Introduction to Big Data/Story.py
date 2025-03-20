import urllib.request
from bs4 import BeautifulSoup
import requests

headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) '
                         'Chrome/51.0.2704.63 Safari/537.36'}

url = "https://store.steampowered.com/"
response = requests.get(url, headers=headers)
data = response.text
print(data)

soup = BeautifulSoup(data, 'html.parser')
header_links = []
for h2 in soup.find_all('h2'):
    a_tag = h2.find('a')
    if a_tag and len(header_links) < 5:
        header_links.append((h2, a_tag['href']))

html_content = "<html><head><title>Crawler</title>5 links:</head><body>"
html_content += "<h1></h1><ul>"

for h2, link in header_links:
    html_content += f"<li><a href='{link}'>{h2.text}</a></li>"

html_content += "</ul></body></html>"

file_path = "D:\Моя папка\Китай\Учёба\introduction\web crawler example-story\story\Crawler.html"
with open(file_path, "w", encoding="utf-8") as f:
    f.write(html_content)

print(f"Saved selected headers with links to {file_path}")
