#!/bin/sh

#Get the Github Token and Giphy API key from Gith Action Inputs
GITHUB_TOKEN=$1
GIPHY_API_KEY=$2

# Get the pull request number from the Github event payload

pull_request_number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
echo PR Number - $pull_request_number

#Use the Giphy Api to fetch a random Thank you Gif

giphy_response=$(curl -s "https://api.giphy.com/v1/gifs/random?api_key=$GIPHY_API_KEY&tag=thank%20you&rating=g")
echo Giphy Response - $giphy_response

# Extrat the GIF URL from Giphy response
gif_url=$(echo "$giphy_response" | jq --raw-output .data.images.downsized.url)

echo GIPHY_URL - $gif_url

# Create a comment with the GIF on the pull request

comment_response=$(curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$pull_request_number/comments \
  -d '{"body":\"### PR - #$pull_request_number. \n ### Thank you for this contribution! \n ![GIF]($gif_url)"}')

#Extract AND PRINT THE COMMENT url for the comment response
comment_url=$(echo "$comment_response" | jq --raw-output .html_url)