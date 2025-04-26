import sys
import requests
from bs4 import BeautifulSoup

def fetch(ticker, exchange):
    url = f"https://www.google.com/finance/quote/{ticker}:{exchange}"
    request = requests.get(url)
    soup = BeautifulSoup(request.text, "html.parser")
    price_element = soup.find(class_="YMlKec fxKbKc")
    
    if price_element:
        price = price_element.text.strip().replace(",", "")
        return price
    else:
        return "Price not found"

if __name__ == "__main__":
    ticker = sys.argv[1]
    exchange = sys.argv[2]
    print(fetch(ticker,exchange))
