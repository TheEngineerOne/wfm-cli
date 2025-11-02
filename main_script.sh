#!/bin/bash

base_url="https://api.warframe.market/v2"
prerequest_buffer=""

search_slug() {
  curl -s "$base_url/items" | jq -r '.data[] | "\(.slug)\t\(.i18n.en.name)"' | fzf --with-nth=2 --delimiter='\t' | cut -f1
}

get_info_from_slug() {
  curl -s "$base_url/item/$1" | jq -r
}

get_orders_from_slug() {
  curl -s "$base_url/orders/item/$1" | jq -r
}

get_ingame_sell_from_slug() {
  get_orders_from_slug "$1" | jq -r '.data[] | select(.type == "sell")' | jq -r 'select(.user.status=="ingame")'
}

get_market_size_from_slug() {
  get_ingame_sell_from_slug "$1" | jq -r '.quantity' | awk '{sum+=$1} END {print sum}'
}

buffered_ingame_sell() {
  echo "$1" | jq -r '.data[] | select(.type == "sell")' | jq -r 'select(.user.status=="ingame")'
}

buffered_market_size() {
  buffered_ingame_sell "$1" | jq -r '.quantity' | awk '{sum+=$1} END {print sum}'
}

prerequest_buffer="$(get_orders_from_slug "$(search_slug)")"
volume="$(buffered_market_size "$prerequest_buffer")"
