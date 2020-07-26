# NearbyFastfood

A restaurant app that finds fast food places nearby using the user's location. Built with MapKit, Yelp REST API and Alamofire. Written programatically.

# Project Status

The app finds fast food places in 4 categories: Burgers, Pizza, Mexican and Chinese. Results are displayed on the map and in the list view. When users select a place, driving directions will be displayed in another screen. Users can select the transport type to see directions via driving or walking. Transit directions are currently disabled, but will be implemented in the next iteration. On the details page, users have the option to share the restaurant's Yelp page or call the business.

# Screenshots

<p float="left">
<img src="https://github.com/mcipswitch/nearby-fastfood/blob/master/Screenshots/fastfoodplaces_mapview.png" width="200">
<img src="https://github.com/mcipswitch/nearby-fastfood/blob/master/Screenshots/fastfoodplaces_listview.png" width="200">
<img src="https://github.com/mcipswitch/nearby-fastfood/blob/master/Screenshots/restaurant_detailsview.png" width="200">
<img src="https://github.com/mcipswitch/nearby-fastfood/blob/master/Screenshots/restaurant_detailsview_share.png" width="200">
</p>

# Reflection

Learning how to use Yelp Fusion with Apple's MapKit API was a great experience. Networking proved challenging, but troubleshooting forced me to research more into Alamofire. In hindsight, I probably could have built this using Apple's URLSession.

Things to do:

* when user selects a cluster pin, the map should zoom in
* fix the annotation flicker when user moves the map
* fix the iOS share sheet delay
* show multiple routes with the option to select
* add driving and walking instructions
* fix details view bug that occassionally shows a cluster pin
* add default image if no business image exists

