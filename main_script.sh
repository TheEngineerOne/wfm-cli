#!/bin/bash

base_url="https://api.warframe.market/v2"
search_slug() {
  curl -s "$base_url/items" | jq -r '.data[] | "\(.slug)\t\(.i18n.en.name)"' | fzf --with-nth=2 --delimiter='\t' | cut -f1
}

get_info_from_slug() {
  curl -s "$base_url/item/$1" | jq -r
}

get_orders_from_slug(){
  curl -s "$base_url/orders/item/$1" | jq -r
}

get_orders_from_slug "$(search_slug)"
